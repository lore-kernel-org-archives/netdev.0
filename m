From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 8/9] net: ethernet: ti: cpts: fix overflow check period
Date: Wed, 14 Sep 2016 23:48:37 +0300
Message-ID: <ebe205d4-9ee4-57db-052b-5f79c7e92286@ti.com>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-9-grygorii.strashko@ti.com>
 <20160914142503.GF28592@localhost.localdomain>
 <d4cde14a-8147-6097-f034-c9cde6cdb718@ti.com> <20160914200845.GB12195@netboy>
 <33f6f81b-ce41-4eba-c62d-93cdb06daa8f@ti.com> <20160914204307.GE12195@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160914204307.GE12195@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/14/2016 11:43 PM, Richard Cochran wrote:
> On Wed, Sep 14, 2016 at 11:23:43PM +0300, Grygorii Strashko wrote:
>> if yes then those changes are correct as from patch#7 point of
>> view, as from patch#8 because they are separate standalone changes.
>> In patch patch#7 it reasonable to ball out earlier, while in patch#8
>> it required to move forward a bit as I need to know maxsec.
>
> And what about the extra blank line?  AFAICT, placing the test later
> in patch #7 is correct logic and has the advantage of not distracting
> reviews with pointless churn!
>

NP. I'll change it.

-- 
regards,
-grygorii
