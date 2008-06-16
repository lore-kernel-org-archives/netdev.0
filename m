From: "Amar Mudrankit" <amar.mudrankit@qlogic.com>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs Documentation
Date: Tue, 17 Jun 2008 01:14:59 +0530
Message-ID: <c8028d330806161244j5a7f46e8y898deea69751d4f6@mail.gmail.com>
References: <20080610205633.11186.45499.stgit@dale>
	 <20080610210918.11186.64253.stgit@dale> <484F751F.7030407@trash.net>
	 <71d336490806120850x3b5e6172jf4d75850771d6349@mail.gmail.com>
	 <485148DA.2060508@trash.net>
	 <c8028d330806121409x27a4d596k571ce87934e89371@mail.gmail.com>
	 <48529027.1090309@trash.net>
	 <c8028d330806131447t2b24be93sa0e07bfa792c8f7f@mail.gmail.com>
	 <48537C68.1010207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	general@lists.openfabrics.org, poornima.kamath@qlogic.com
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:60049 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbYFPTpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 15:45:03 -0400
Received: by rv-out-0506.google.com with SMTP id k40so3788997rvb.1
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2008 12:45:01 -0700 (PDT)
In-Reply-To: <48537C68.1010207@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I was looking at latest release of iproute2, in which I could not
>> locate fill_xstats. Can you help me to locate this?
>
> ->fill_xstats is in the kernel, in iproute its ->print_xstats.

I was looking at kernel code net/8021q/vlan_netlink.c on which I have
following queries:

a.  Is it a correct file in kernel I m referring to?
b.  vlan_fill_info is a function to send parameters back to user
level. What is the role of skb as an argument to function? Is some
network operation expected?
c.  How exactly the kernel API ops->get_size comes into play? I guess
user prog should first get the size of parameters that will be
returned by driver before calling ops->fill_info.
d.  Can somebody briefly introduce struct nlattr? It looks like all
parameters flow through this structure.

Thanks and Regards,
Amar S Mudrankit
