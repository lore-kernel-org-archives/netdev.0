From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: RE: [RFC v3 00/11] HFI Virtual Network Interface Controller (VNIC)
Date: Wed, 8 Feb 2017 17:21:29 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373AB0E5F8C@ORSMSX109.amr.corp.intel.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
         <1486502926.2581.4.camel@sandisk.com>
         <1828884A29C6694DAF28B7E6B8A82373AB0E5B6C@ORSMSX109.amr.corp.intel.com>
         <1486504716.2581.8.camel@sandisk.com>
         <20170208005416.GA76793@knc-06.sc.intel.com>
 <1486516168.2581.21.camel@sandisk.com>
 <2807E5FD2F6FDA4886F6618EAC48510E3C644BF1@CRSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "Dalessandro, Dennis" <dennis.dalessandro@intel.com>,
        "dledford@redhat.com" <dledford@redhat.com>
To: "Weiny, Ira" <ira.weiny@intel.com>,
        Bart Van Assche <Bart.VanAssche@sandisk.com>,
        "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7722 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753533AbdBHRVa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 12:21:30 -0500
In-Reply-To: <2807E5FD2F6FDA4886F6618EAC48510E3C644BF1@CRSMSX101.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Even reading your statement twice did not make me any wiser.
> > You mentioned "better hardware resource usage". Compared to what? Is
> that
> > perhaps compared to IPoIB?  Since Ethernet frames have an extra
> header and
> > are larger than IPoIB frames, how can larger frames result in better
> hardware
> > resource usage?
> 
> Yes, as compared to IPoIB.  The problem with IPoIB is it introduces a
> significant amount of Verbs overhead which is not needed for Ethernet
> encapsulation.  Especially on hardware such as ours.  As Jason has
> mentioned having a more generic "skb_send" or "skb_qp" has been
> discussed in the past.

Let's start discussing whether ipoib should be in the upstream kernel while we're at this nonsense.

The IBTA chose to encapsulate IP over IB transport as their mechanism for supporting traditional socket based applications.  OPA chose Ethernet encapsulated over OPA link layer.  RDMA isn't involved with OPA.  This is a pointless discussion over architecture.
