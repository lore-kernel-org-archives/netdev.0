From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: UDP Out 0f Sequence
Date: Thu, 21 Sep 2006 15:59:05 +1200
Message-ID: <5640c7e00609202059p74c1c653t8a97fb873915f5d@mail.gmail.com>
References: <F444CAE5E62A714C9F45AA292785BED30EB97599@esng11p33001.sg.csfb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Rick Jones" <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.131]:35830 "EHLO
	nf-out-f131.google.com") by vger.kernel.org with ESMTP
	id S1751192AbWIUD7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 23:59:12 -0400
Received: by nf-out-f131.google.com with SMTP id k65so632725nfa
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2006 20:59:11 -0700 (PDT)
To: "Majumder, Rajib" <rajib.majumder@credit-suisse.com>
In-Reply-To: <F444CAE5E62A714C9F45AA292785BED30EB97599@esng11p33001.sg.csfb.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/21/06, Majumder, Rajib <rajib.majumder@credit-suisse.com> wrote:
> Does this mean if we have 2 hosts connected back to back (there's no network device in between), sequence is guaranteed even in UDP?
>
I think if you're trying to make the packets appear in order you need
to untie the Gordian knot http://en.wikipedia.org/wiki/Gordian_Knot

In other words you should fix the application rather than the near
impossible task of trying to make the packets in order...

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
