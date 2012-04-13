From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH] netfilter: ipvs: Verify that IP_VS protocol has been registered
Date: Fri, 13 Apr 2012 02:54:13 +0200
Message-ID: <CA+1xoqcxggYxb_ha4VdQtCUW-iYeVbaB38mC_pwAzdCf=rS7mQ@mail.gmail.com>
References: <1333668273-8873-1-git-send-email-levinsasha928@gmail.com>
 <20120411232243.GB7038@1984> <20120411234628.GA7253@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg,
	kaber@trash.net, davem@davemloft.net, davej@redhat.com,
	netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120411234628.GA7253@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 12, 2012 at 1:46 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>> If you return here, I think you'll leave things in inconsistent state,
>> ie. the tcp protocol is registered. You have to unregister it before
>> leaving.

I thought that the cleanup callback is getting called for failed init
calls, if that's not the case then we can probably call it ourselves
if any of these failed.
