From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: Re: [PATCH 00/18] Export SPI and OF module aliases in missing drivers
Date: Thu, 20 Aug 2015 23:50:50 +0200
Message-ID: <55D64BBA.7070802@osg.samsung.com>
References: <1440054451-1223-1-git-send-email-javier@osg.samsung.com>
 <20150820211152.GI74600@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev@vger.kernel.org, linux-iio@vger.kernel.org,
 linux-mmc@vger.kernel.org, Krzysztof Kozlowski <k.kozlowski@samsung.com>,
 Adrian Hunter <adrian.hunter@intel.com>, Andrzej Hajda <a.hajda@samsung.com>,
 netdev@vger.kernel.org, linux-mtd@lists.infradead.org,
 Peter Meerwald <pmeerw@pmeerw.net>, Lee Jones <lee.jones@linaro.org>,
 Aloisio Almeida Jr <aloisio.almeida@openbossa.org>, devel@driverdev.osuosl.org,
 Lars-Peter Clausen <lars@metafoo.de>, Stephen Warren <swarren@nvidia.com>,
 Samuel Ortiz <sameo@linux.intel.com>,
 =?UTF-8?Q?S=c3=b8ren_Andersen?= <san@rosetechnology.dk>,
 Andrea Galbusera <gizero@gmail.com>, Antonio Borneo <borneo.antonio@gmail.com>,
 Tomi Valkeinen <tomi.valkeinen@ti.com>, Ulf Hansson <ulf.hansson@linaro.org>,
 Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
 linux-media@vger.kernel.org, Michael Hennerich <Michael.Hennerich@analog.com>,
 Mauro
To: Brian Norris <computersforpeace@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20150820211152.GI74600@google.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Hello Brian,

On 08/20/2015 11:11 PM, Brian Norris wrote:
> On Thu, Aug 20, 2015 at 09:07:13AM +0200, Javier Martinez Canillas wrote:
>> Patches #1 and #2 solves a), patches #3 to #8 solves b) and patches
> 
> ^^^ I'm dying to know how this sentence ends :)
>

Sigh, I did some last minute restructuring of the cover letter and
seems I missed a sentence. I meant to said:

"and patches #9 to #17 solves c)."
 
>> Patch #18 changes the logic of spi_uevent() to report an OF modalias if
>> the device was registered using OF. But this patch is included in the
>> series only as an RFC for illustration purposes since changing that
>> without first applying all the other patches in this series, will break
>> module autoloading for the drivers of devices registered using OF but
>> that lacks an of_match_table. I'll repost patch #18 once all the patches
>> in this series have landed.
> 
> On a more productive note, the patches I've looked at look good to me.
> The missing aliases are a problem enough that should be fixed (i.e.,
> part (b)). I'll leave the SPI framework changes to others to comment on.
>

Great, thanks a lot for your feedback.
 
> Brian
> 

Best regards,
-- 
Javier Martinez Canillas
Open Source Group
Samsung Research America
