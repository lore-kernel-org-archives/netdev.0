From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 0/3] bluetooth: bug fixes for 3.3
Date: Wed, 14 Mar 2012 11:16:54 -0700
Message-ID: <1331749014.14217.112.camel@aeonflux>
References: <1331307806-21761-1-git-send-email-jhovold@gmail.com>
	 <20120314112543.GA5136@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	David Herrmann <dh.herrmann@googlemail.com>,
	Greg KH <gregkh@linuxfoundation.org>
To: Johan Hovold <jhovold@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120314112543.GA5136@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Johan,

> > This is a revised series which also contains a minimal fix to the memory leak
> > discovered by David Hermann upon which the first NULL-pointer-dereference fix
> > also depends.
> > 
> > These patches need to get to Linus ASAP as the problems are present in 3.3-rc6
> > as well as earlier kernels and thus should be backported to the stable trees as
> > well.
> 
> Any chance to get these into 3.3? Otherwise, is it possible to rebase
> bluetooth-next on top of these so that Greg can get them into 3.3.1 (and
> the other stable trees) once bluetooth-next is merged?
> 
> All three bugs can be used to crash any kernel with HCI-UART support and
> can probably be used for exploits as they are extremely easy to trigger
> reliably.

only if you have access to the TTY device node in the first place. If
you do not have access to that device node, you can not crash the
kernel.

Can you resend a clean set of patches for bluetooth-next and once we
have that merged, we can talk on how to backport this to 3.3 and also
-stable.

Regards

Marcel
