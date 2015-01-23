From: Sun Paul <paulrbk@gmail.com>
Subject: Fwd: Question on SCTP ABORT chunk is generated when the
 association_max_retrans is reached
Date: Fri, 23 Jan 2015 18:25:01 +0800
Message-ID: <CAFXGft+fwo=8LJEG7h6uOpGciSo5f_dXjSx3sn67RZZp7jsYHw@mail.gmail.com>
References: <CAFXGftKp3=OfjkCVBuR-zM3+uZ42Sk_9i2UjAHBNnbX=hQJwpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFXGftKp3=OfjkCVBuR-zM3+uZ42Sk_9i2UjAHBNnbX=hQJwpA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

I would like to check the behave in LKSCTP.

we are running DIAMETER message over SCTP, and we have set the
parameter "net.sctp.association_max_retrans = 4" in the LinuxOS.

We noticed that when remote peer have retry to send the same request
for 4 times, the LKSCTP will initiate an ABORT chunk with reason
"association exceeded its max_retrans count".

We would like to know whether this is the correct behavior? is there
any other option that we can alter in order to avoid the ABORT chunk
being sent?

Thanks

PS
