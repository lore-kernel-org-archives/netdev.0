From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 0/2] flower: add MPLS matching support
Date: Mon, 24 Apr 2017 19:07:43 -0700
Message-ID: <20170424190743.4ad24ad1@cakuba.netronome.com>
References: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
        <20170424.143257.1003081554810761464.davem@davemloft.net>
        <d54cca4b-6212-bf7d-93e2-8314177df42c@mojatatu.com>
        <20170424182054.116d1a99@cakuba.netronome.com>
        <6ae82894-fc8b-2ad9-7dfd-cf74cd6042a1@mojatatu.com>
        <e58fd7ee-1bd0-0cd5-ab15-c510ec4e70bd@mojatatu.com>
        <8f6e7952-b87b-8959-b45a-ab687b69fb1b@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, benjamin.lahaise@netronome.com,
        netdev@vger.kernel.org, bcrl@kvack.org,
        Jiri Pirko <jiri@resnulli.us>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:22583 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S979932AbdDYCIB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 22:08:01 -0400
In-Reply-To: <8f6e7952-b87b-8959-b45a-ab687b69fb1b@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Apr 2017 22:06:08 -0400, Jamal Hadi Salim wrote:
> On 17-04-24 10:00 PM, Jamal Hadi Salim wrote:
> > On 17-04-24 09:48 PM, Jamal Hadi Salim wrote:  
> 
> >
> > Hrm. maybe I am wrong.
> > Lets say user sets all of the 8 bits in BOS,
> > what does setting
> > key_val->mpls_bos = nla_get_u8 do?
> >
> > Same with the 20 bits for the label in the u32
> > or 3 bit bits in the u8 tc.  
> 
> The label and tc are masked - maybe just the BOS
> needs something similar?

Indeed, good catch!
