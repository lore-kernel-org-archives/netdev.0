From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC 00/11] QLogic RDMA Driver (qedr) RFC
Date: Wed, 14 Sep 2016 11:17:37 -0600
Message-ID: <20160914171737.GH16014@obsidianresearch.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <20160912180508.GI5843@obsidianresearch.com>
 <DM3PR1101MB1181DF570D4F01A0CEB1CFC7E2FE0@DM3PR1101MB1181.namprd11.prod.outlook.com>
 <20160913154000.GA25878@obsidianresearch.com>
 <SN1PR07MB2207486633D88B5C65D547F9F8F10@SN1PR07MB2207.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dledford@redhat.com" <dledford@redhat.com>,
        David Miller <davem@davemloft.net>,
        Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Ariel Elior <Ariel.Elior@qlogic.com>,
        Michal Kalderon <Michal.Kalderon@qlogic.com>,
        Rajesh Borundia <rajesh.borundia@qlogic.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: "Amrani, Ram" <Ram.Amrani@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:33171 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761935AbcINRRs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 13:17:48 -0400
Content-Disposition: inline
In-Reply-To: <SN1PR07MB2207486633D88B5C65D547F9F8F10@SN1PR07MB2207.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2016 at 02:44:47PM +0000, Amrani, Ram wrote:
> > Anything that is used with copy_to/from_user, ib_copy_to/from_udata, 
> > etc, etc must be in a include/uapi header.
> > 
> > Any constant you might want to copy into your userspace provider must 
> > be in include/uapi.
> > 
> I understand you mean something like
> https://www.spinics.net/lists/linux-rdma/msg40414.html ([RFC
> rdma-next 0/3] Move mlx5 vendor specific to UAPI directory)

Yes.

> > Avoid copying headers in your user space and use the standard kernel 
> > names to access your driver's uapi.

> So the user library should be able to compile against these headers
> in their location and not hold identical copies.

Yes, but you will need identical copies for supporting old distros.

> What do you mean by "standard kernel names"?

By that I mean 'identical copies' do not copy the file and then
randomly change it giving things different names or putting different
content in structs.

You will want to submit your user provider to rdma-plumbing to get it
into the distros, we are planning to set it as the vehicle for code
targeting 4.9

Jason
