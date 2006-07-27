From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Create IP100A Driver
Date: Thu, 27 Jul 2006 09:06:26 -0400
Message-ID: <20060727130626.GB8794@hmsreliant.homelinux.net>
References: <1154030065.5967.15.camel@localhost.localdomain> <20060727125421.GB22935@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Huang <jesse@icplus.com.tw>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@osdl.org, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751293AbWG0NIO@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20060727125421.GB22935@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 27, 2006 at 08:54:27AM -0400, John W. Linville wrote:
> On Thu, Jul 27, 2006 at 03:54:25PM -0400, Jesse Huang wrote:
> > From: Jesse Huang <jesse@icplus.com.tw>
> > 
> > This is the first version of IP100A Linux Driver.
> 
> One general comment is that your patch is whitespace-damaged,
> undoubtedly mangled by your mailer.  I would suggest that you use
> a text- or curses-based mailer (like mutt or even mail) for sending
> patches, but I'm sure there are graphical mailers that can be trained
> to not be "too smart".
> 
> > +static struct pci_device_id ipf_pci_tbl[] __devinitdata = {
> > +       {0x1186, 0x1002, 0x1186, 0x1002, 0, 0, 0},
> > +       {0x1186, 0x1002, 0x1186, 0x1003, 0, 0, 1},
> > +       {0x1186, 0x1002, 0x1186, 0x1012, 0, 0, 2},
> > +       {0x1186, 0x1002, 0x1186, 0x1040, 0, 0, 3},
> > +       {0x1186, 0x1002, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 4},
> > +       {0x13F0, 0x0201, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 5},
> > +       {0x13F0, 0x0200, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 6},
> > +       {0,}
> > +};
> 
> This PCI ID table is identical to the one in the sundance driver.
> What advantage does this driver offer over sundance?
> 
> Thanks,
> 
> John

Having read Johns comment, I went back and looked again, and in fact the entire
driver appears to be a copy of the sundance code.  The most significant changes
I can see is that the header includes were moved to ipf.h, and the non-standard
data types (UINT/UCHAR/etc) were added.

Regards
Neil

> -- 
> John W. Linville
> linville@tuxdriver.com
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *gpg keyid: 1024D / 0x92A74FA1 - http://pgp.mit.edu
 ***************************************************/
