From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Question on SCTP ABORT chunk is generated when the association_max_retrans
 is reached
Date: Mon, 26 Jan 2015 14:30:54 +0100
Message-ID: <54C6418E.1010408@redhat.com>
References: <CAFXGftKp3=OfjkCVBuR-zM3+uZ42Sk_9i2UjAHBNnbX=hQJwpA@mail.gmail.com> <CAFXGft+fwo=8LJEG7h6uOpGciSo5f_dXjSx3sn67RZZp7jsYHw@mail.gmail.com> <54C23581.9060809@redhat.com> <54C27137.5010405@gmail.com> <54C2807E.8080607@redhat.com> <8BBFBEE6-FA34-4190-BFCB-AB6BEC093774@fh-muenster.de> <54C29B82.7090502@redhat.com> <CAFXGft+XZCmhuwj2QTCiU0MD10Uo+WZ3WCC+rfbsd_Lxbhk3iw@mail.gmail.com> <54C62912.3040401@gmail.com> <CAFXGftJNZ48Qe4DLgf5TPBvNCnUH8wxon9+b3_i_GWVYqnphhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Michael Tuexen <tuexen@fh-muenster.de>,
	Vlad Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sun Paul <paulrbk@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFXGftJNZ48Qe4DLgf5TPBvNCnUH8wxon9+b3_i_GWVYqnphhg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/26/2015 02:17 PM, Sun Paul wrote:
> When an ABORT is sent to side-A, side-A INIT a new connection again.

Even if the ABORT is not being sent, the peer (the one who would send
his ABORT) closes the TCB from his side silently then. Any messages that
would afterwards arrive on this dead connection would be answered with
an oob ABORT just as well. I'm still missing the bigger picture on your
use-case scenario here, I guess ... why is the recommended rtx limit not
sufficient?
