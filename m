From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Re: [1/1] connector/CBUS: new messaging subsystem. Revision number next.
Date: Wed, 27 Apr 2005 00:16:33 -0500
Message-ID: <200504270016.34002.dtor_core@ameritech.net>
References: <20050411125932.GA19538@uganda.factory.vocord.ru> <d120d500050426130250ff9632@mail.gmail.com> <1114574809.14282.10.camel@uganda>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@oss.sgi.com, Greg KH <greg@kroah.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	James Morris <jmorris@redhat.com>,
	Guillaume Thouvenin <guillaume.thouvenin@bull.net>,
	linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	Thomas Graf <tgraf@suug.ch>, Jay Lan <jlan@engr.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261482AbVD0FQj@vger.kernel.org>
To: johnpol@2ka.mipt.ru
In-Reply-To: <1114574809.14282.10.camel@uganda>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 26 April 2005 23:06, Evgeniy Polyakov wrote:
> Let's clarify that we are talking about userspace->kernelspace
> direction.
> Only for that messages callback path is invoked.

What about kernelspace->userspace or kernelspace->kernelspace?
>From what I see nothing stops kernel code from calling cn_netlink_send,
in fact your cbus does exactly that. So I am confused why you singled
out userspace->kernelspace direction.

-- 
Dmitry
