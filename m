From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] tipc: use kconfig to limit numeric ranges
Date: Fri, 25 Dec 2009 12:36:14 +0800
Message-ID: <4B34413E.7060600@redhat.com>
References: <20091225032956.4556.69130.sendpatchset@localhost.localdomain> <31665.1261713006@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Allan Stephens <allan.stephens@windriver.com>,
	netdev@vger.kernel.org, Per Liden <per.liden@ericsson.com>,
	tipc-discussion@lists.sourceforge.net, akpm@linux-foundation.org,
	Jon Maloy <jon.maloy@ericsson.com>
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752191AbZLYEeO@vger.kernel.org>
In-Reply-To: <31665.1261713006@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Valdis.Kletnieks@vt.edu wrote:
> On Thu, 24 Dec 2009 22:26:48 EST, Amerigo Wang said:
>> We can rely on kconfig to limit these numbers,
>> no need to limit them at compile time/run time.
> 
>> +          ***Only 1 (one cluster in a zone) is supported by current code.***
>>  
>>            (Max number of clusters inside TIPC zone. Max supported 
>>            value is 4095 clusters, minimum is 1.
> 
> Given the limit of 1, maybe the reference to 4095 should be nuked?
> 

I am not sure, I think the limit of 1 is a temporary choice currently.
