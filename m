From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 4/9] net: ethernet: ti: cpts: move dt props parsing to
 cpts driver
Date: Wed, 14 Sep 2016 22:45:54 +0300
Message-ID: <179724dc-dcc2-6052-84c6-eef9807d867c@ti.com>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-5-grygorii.strashko@ti.com>
 <20160914135535.GB28592@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160914135535.GB28592@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/14/2016 04:55 PM, Richard Cochran wrote:
> On Wed, Sep 14, 2016 at 04:02:26PM +0300, Grygorii Strashko wrote:
>> Move DT properties parsing into CPTS driver to simplify consumer's
>> code and CPTS driver porting on other SoC in the future
>> (like Keystone 2).
> 
> And just who is the consumer?

Now CPSW, and Keystone 2 netcp in the future.

>  
>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
>> ---
>>  drivers/net/ethernet/ti/cpsw.c | 16 +---------------
>>  drivers/net/ethernet/ti/cpsw.h |  2 --
>>  drivers/net/ethernet/ti/cpts.c | 29 ++++++++++++++++++++++++++---
>>  drivers/net/ethernet/ti/cpts.h |  5 +++--
>>  4 files changed, 30 insertions(+), 22 deletions(-)
> 
> You have more (+) than (-).  I wouldn't call that a simplification.


With this change It will not be required to add the same DT parsing code
in Keystone 2 netcp driver, so overall number of lines will be reduced.

As I mentioned in cover letter - this is preparation step and this series
 indented help and simplify CPTS integration with few TI net drivers
(now cpsw, soon KS2 netcp), because similar CPTS IP is integrated
in two different TI's SoC families (and might be in more the future).  

I've not posted KS2 patches here, because of two reasons:
- they are still under internal review
- I hate big patch series

-- 
regards,
-grygorii
