From: corbet@lwn.net (Jonathan Corbet)
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Tue, 27 Nov 2007 08:43:24 -0700
Message-ID: <25602.1196178204@lwn.net>
References: <200711271549.37670.rusty@rustcorp.com.au>
Cc: Andi Kleen <ak@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org,
	Roland Dreier <rdreier@cisco.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758806AbXK0Pnf@vger.kernel.org>
In-reply-to: Your message of "Tue, 27 Nov 2007 15:49:37 +1100."
             <200711271549.37670.rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rusty said:

> Well, introduce an EXPORT_SYMBOL_INTERNAL().  It's a lot less code.  But you'd 
> still need to show that people are having trouble knowing what APIs to use.

Might the recent discussion on the exporting of sys_open() and
sys_read() be an example here?  There would appear to be a consensus
that people should not have used those functions, but they are now
proving difficult to unexport.

Perhaps the best use of the namespace stuff might be for *future*
exports which are needed to help make the mainline kernel fully modular,
but which are not meant to be part of a more widely-used API?

jon
