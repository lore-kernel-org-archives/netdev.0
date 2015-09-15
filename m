From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH V2] debugfs: don't assume sizeof(bool) to be 4 bytes
Date: Tue, 15 Sep 2015 07:34:38 +0530
Message-ID: <20150915020438.GG32551@linux>
References: <81516fb9c662cc338b5af5b63fbbcde5374e0893.1442202447.git.viresh.kumar@linaro.org>
 <1708603.aKpYchk1pa@wuerfel>
 <20150914154708.GF32551@linux>
 <20150914160348.GA7290@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, linaro-kernel@lists.linaro.org,
	"open list:NETWORKING DRIVERS WIRELESS" <linux-wireless@vger.kernel.org>,
	"moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>,
	Avri Altman <avri.altman@intel.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Mark Brown <broonie@kernel.org>, Jaroslav Kysela <perex@perex.cz>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Wang Long <long.wanglong@huawei.com>,
	Richard Fitzgerald <rf@opensource.wolfsonmicro.com>,
	Ingo Molnar <mingo@kernel.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	Davidlohr Bueso <dave@stg
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20150914160348.GA7290@kroah.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 14-09-15, 09:03, Greg KH wrote:
> What ever ones you think it is relevant for :)

"Relevant" is a relevant term :)

So, the patch which defined the type bool as _Bool was added in v2.6.19 :)

6e2182874324 ("[PATCH] Generic boolean")

So, I will try at least for v3.10+ as they are used by a lot of
people, as they are LTS kernels. But wasn't sure if I should do it
right from 2.6.19.

-- 
viresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
