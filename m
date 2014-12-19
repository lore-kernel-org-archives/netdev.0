From: Rajat Jain <rajatxjain@gmail.com>
Subject: Re: [bisected] tg3 broken in 3.18.0?
Date: Fri, 19 Dec 2014 11:37:55 -0800
Message-ID: <CAA93t1qsPE=otZNe-Bf5yYiWtB_Zrf4q8zAiFApUNqpm8Gt28A@mail.gmail.com>
References: <20141213210251.GA12812@teela.fritz.box>
	<548EF90A.5070607@gmail.com>
	<CAA93t1qyZE-9tw8pg1KG6g4iyy0QMW=iass5w=6ZGMTMu+vi_A@mail.gmail.com>
	<CAErSpo5dqQE7nZ6zf2odgpHBWA3ZpTjhbgQKnY8YxQW+a+298w@mail.gmail.com>
	<1418750141.4248.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<54907300.9050902@gmail.com>
	<1418759684.4248.12.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<CAErSpo7sqZS+-4LHo3wbo-pa73mcP_3d0Z37U0tfnASaxp-D_g@mail.gmail.com>
	<1418930889.3433.8.camel@prashant>
	<20141218202637.GA2930@teela.fritz.box>
	<1418955047.3433.27.camel@prashant>
	<CAErSpo4UdxwL=wA8cBJ7_DAdTb2xNeg6600qB0=Jdxv80aVmcg@mail.gmail.com>
	<54945D79.2070008@gmail.com>
	<CAA93t1qOUZEmJEcuUNtkDS0M_pafb_1s==9Yqm9-+-+OmJmVuQ@mail.gmail.com>
	<1419015228.27773.3.camel@prashant>
Reply-To: rajatxjain@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Nils Holland <nholland@tisys.org>,
	Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Rafael Wysocki <rjw@rjwysocki.net>
To: Prashant Sreedharan <prashant@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1419015228.27773.3.camel@prashant>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 19, 2014 at 10:53 AM, Prashant Sreedharan
<prashant@broadcom.com> wrote:
> On Fri, 2014-12-19 at 10:24 -0800, Rajat Jain wrote:
>> One of the reasons to replace the condition (*l == 0xffff0001) with
>> (*l & 0xffff) == 0x0001) was that some devices apparently returned
>> 0001 for device id to indicate CRS, but returned actual vendor id in
>> the vendor ID field (hence the need to ignore vendor field).
>>
>> Are we saying that the tg3 device returns 0x0001 for the device ID and
>> yet expects it to be treated as a good value (not CRS)?
>>
> No it should not be treated as a good value, this commit has
> surfaced/exposed a problem in 5722 chipset which was previously masked.
>

Got it. Thanks.

I assume you mean its a HW issue, and the workaround if required shall
be taken care in tg3 driver.

Thanks,

Rajat

>
>
