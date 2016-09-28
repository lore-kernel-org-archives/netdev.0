From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 3/5] ISDN-Gigaset: Delete an error message for a failed
 memory allocation
Date: Wed, 28 Sep 2016 13:42:38 +0200
Message-ID: <1475062958.16606.31.camel@tiscali.nl>
References: <566ABCD9.1060404@users.sourceforge.net>
         <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
         <64f7ba12-1b0e-9fac-9b2e-d22e7fb3fcc7@users.sourceforge.net>
         <1474973851.1608488.738293513.6CA62927@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        Wolfram Sang <wsa@the-dreams.de>
To: Tilman Schmidt <tilman@imap.cc>,
        SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474973851.1608488.738293513.6CA62927@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-09-27 at 12:57 +0200, Tilman Schmidt wrote:
> On Mon, Sep 26, 2016, at 17:42, SF Markus Elfring wrote:
> > Omit an extra message for a memory allocation failure in this
> > function.
> > 
> > Link:
> > http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-R
> > efactor_Strings-WSang_0.pdf
> > 
> > Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> 
> The patch is fine but the link in the commit message is irrelevant.
> Please remove it.
> (Yes, I read through the whole presentation to verify that. It was fun,
> even.)

Agree.

Except this patch assumes the superfluous braces would be removed in
4/5. But it turns out that other patch must be dropped. It would have
been better to remove the braces in this patch.


Paul Bolle
