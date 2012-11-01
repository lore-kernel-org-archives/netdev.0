From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Wed, 31 Oct 2012 18:22:54 -0700
Message-ID: <CAOxq_8OnKhLMqdgj=LBiHyYwqjE82-qjcGLiUUcp14RzK8P7YA@mail.gmail.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<5422DBB2-EABF-4C9F-B0CD-8C77E91F9FF8@alum.mit.edu>
	<CAOxq_8O8Vkm5Napp_h6HVj6C=EH2gd_PQJJ1N5d_VQZrRZFYNQ@mail.gmail.com>
	<B23C28F0-4005-4970-984D-3BAD063EA513@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>,
	tcpdump-workers@lists.tcpdump.org
To: Guy Harris <guy@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:37760 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760190Ab2KABWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 21:22:55 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so2190150vcb.19
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 18:22:55 -0700 (PDT)
In-Reply-To: <B23C28F0-4005-4970-984D-3BAD063EA513@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 31, 2012 at 5:50 PM, Guy Harris <guy@alum.mit.edu> wrote:
>
> On Oct 31, 2012, at 3:35 PM, Ani Sinha <ani@aristanetworks.com> wrote:
>
>> yes but if the packet is passed to the filter within libpcap (when we
>> are not using the kernel filter) before the reinsertion,
>
> ...that would be a bug.
>
> Currently, that bug doesn't exist in the recvfrom() code path, but *does* appear to exist in the tpacket code path - and that code path also runs the filter before the SLL header is constructed.  That should be fixed.


yes, agreed.
