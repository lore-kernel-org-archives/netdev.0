From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [ethtool PATCH v4 0/4]  Add support for QSFP+/QSFP28 Diagnostics
 and 25G/50G/100G      port speeds
Date: Wed, 24 Aug 2016 10:33:04 -0400
Message-ID: <20160824143304.GB20493@tuxdriver.com>
References: <1471959033-1053-1-git-send-email-vidya@cumulusnetworks.com>
 <SN2PR11MB009470F680A2B7697167965097EA0@SN2PR11MB0094.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        "decot@googlers.com" <decot@googlers.com>,
        "bkenward@solarflare.com" <bkenward@solarflare.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "galp@mellanox.com" <galp@mellanox.com>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        "gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
        "dustin@cumulusnetworks.com" <dustin@cumulusnetworks.com>,
        "ben@decadent.org.uk" <ben@decadent.org.uk>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39573 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756387AbcHXP4w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 11:56:52 -0400
Content-Disposition: inline
In-Reply-To: <SN2PR11MB009470F680A2B7697167965097EA0@SN2PR11MB0094.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 04:29:22AM +0000, Yuval Mintz wrote:
> > This patch series provides following support
> > a) Reorganized fields based out of SFF-8024 fields i.e. Identifier/
> >    Encoding/Connector types which are common across SFP/SFP+ (SFF-8472)
> >    and QSFP+/QSFP28 (SFF-8436/SFF-8636) modules into sff-common files.
> > b) Support for diagnostics information for QSFP Plus/QSFP28 modules
> >    based on SFF-8436/SFF-8636
> > c) Supporting 25G/50G/100G speeds in supported/advertising fields
> > d) Tested across various QSFP+/QSFP28 Copper/Optical modules
> > 
> > Standards for QSFP+/QSFP28
> > a) QSFP+/QSFP28 - SFF 8636 Rev 2.7 dated January 26,2016
> > b) SFF-8024 Rev 4.0 dated May 31, 2016
> > 
> > v4:
> >   Sync ethtool-copy.h to kernel commit
> > 89da45b8b5b2187734a11038b8593714f964ffd1
> >   which includes support for 50G base SR2
> 
> What about the man-page?

I can just apply your man page patch on top.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
