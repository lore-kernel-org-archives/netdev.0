From: Mateusz Berezecki <mateuszb@gmail.com>
Subject: Re: atheros driver - desc
Date: Fri, 5 Aug 2005 20:07:09 +0200
Message-ID: <20050805180709.GD3067@ntjohd.mshome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <kernel-mentors-bounces@selenic.com>
To: kernel-mentors@selenic.com
Content-Disposition: inline
List-Unsubscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=unsubscribe>
List-Archive: <http://www.selenic.com/pipermail/kernel-mentors>
List-Post: <mailto:kernel-mentors@selenic.com>
List-Help: <mailto:kernel-mentors-request@selenic.com?subject=help>
List-Subscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=subscribe>
Sender: kernel-mentors-bounces@selenic.com
Errors-To: kernel-mentors-bounces@selenic.com
List-Id: netdev.vger.kernel.org

On 09:46 Fri 05 Aug     , Bryan O'Sullivan wrote:
> On Fri, 2005-08-05 at 04:55 +0200, Mateusz Berezecki wrote:
> 
> How far from working is it?  I have a miniPCI Atheros card and would be
> interested in helping out with bringing the driver up, but it would be
> good to know what to expect first :-)
> 

HAL is completely reversed, and it appears to work quite good. I have
tested quite a lot using *cough* hardcoded solutions :-)


What the driver is missing is integration with ieee80211 API
from netdev tree, Wireless Extensions and I've recently added
empty ioctl function templates. Basically that's what is missing.
Nothing more, nothing less :-)

And regarding that ieee80211 API, I would be very excited if
anyone could explain the general overview of how new wireless
API works. I read the source but sometimes a quick answer from
experienced kernel coder would do more good. 


kind regards
Mateusz
