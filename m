From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v2 0/5] bridge: per vlan dst_metadata support
Date: Wed, 1 Feb 2017 20:04:18 -0800
Message-ID: <20170201200418.6f4ee3aa@xeon-e3>
References: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com>
        <20170202012301.GA74213@ast-mbp.thefacebook.com>
        <28b36ff5-a54c-7af6-3cb3-adffa5cfad46@cumulusnetworks.com>
        <5892AF5B.3040504@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        netdev@vger.kernel.org, davem@davemloft.net,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        hadi@mojatatu.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34537 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750774AbdBBEE0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 23:04:26 -0500
Received: by mail-pf0-f172.google.com with SMTP id e4so1705610pfg.1
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 20:04:26 -0800 (PST)
In-Reply-To: <5892AF5B.3040504@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Feb 2017 20:02:35 -0800
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> On 2/1/17, 5:59 PM, David Ahern wrote:
> > On 2/1/17 6:23 PM, Alexei Starovoitov wrote:  
> >> On Tue, Jan 31, 2017 at 10:59:50PM -0800, Roopa Prabhu wrote:  
> >>>                     
> >>> This provides the required vxlan bridging function but poses a
> >>> scalability problem with using a separate vxlan netdev for each vni.  
> >> if I remember correctly this issue was the main reason David Ahern
> >> put netdev on diet. Sounds like no more fun at netconf ;)
> >>  
> > oh, it still needs a diet ...  
>  Even if the netdev went on diet, a netdev per vni for vxlan deployments is just too much overhead.
> 
> 

But the intent was VNI == VLAN tag and there are cases where you need per VNI rules.
Having them all smashed into one netdev seems like a step in the wrong direction.
