From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Fri, 27 Apr 2012 11:46:38 +0200
Message-ID: <20120427094637.GV3157@wantstofly.org>
References: <1335517711-6522-1-git-send-email-sedat.dilek@gmail.com>
 <20120427091405.GS3157@wantstofly.org>
 <CA+icZUVAK3NHmbG5kR1KhqGe9mAimWWzLz-MfXOXbyry3Sz73w@mail.gmail.com>
 <20120427094007.GU3157@wantstofly.org>
 <CA+icZUUiYwpHpqe5_kz1rLzTT13qQMwpNpDH7EOaRrVi_c8Z2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sedat.dilek@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+icZUUiYwpHpqe5_kz1rLzTT13qQMwpNpDH7EOaRrVi_c8Z2Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 27, 2012 at 11:42:54AM +0200, Sedat Dilek wrote:

> >> Are you planning to or even working on support (for) 8361 devices?
> >
> > I don't have any such plans, and I don't know of anyone who does.
> 
> Does 8361 require firmware support?

What do you mean by that?


> Does a firmware file exist (name?)?

There's firmware for the 8361 out there, however, that version of
the firmware implements a firmware API that is different from the
one that mwl8k currently implements.

You could add 8361 support to mwl8k, but then you'd have to go over
all the firmware command invocations in mwl8k and make sure that they
will work on the 8361 firmware that you're trying to support as well.
