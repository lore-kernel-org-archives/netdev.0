From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V3 2/2] debugfs: don't assume sizeof(bool) to be 4 bytes
Date: Tue, 15 Sep 2015 10:29:29 -0400
Message-ID: <20150915142929.GB2905@mtj.duckdns.org>
References: <9b705747a138c96c26faee5218f7b47403195b28.1442305897.git.viresh.kumar@linaro.org>
	<27d37898b4be6b9b9f31b90135f8206ca079a868.1442305897.git.viresh.kumar@linaro.org>
	<20150915100454.70dcc04d@gandalf.local.home>
	<20150915141208.GK6350@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "open list:NETWORKING DRIVERS \(WIRELESS\)"
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..."
	<alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org>, Avri Altman <avri.altman-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"open list:DOCUMENTATION" <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	Sebastian Andrzej Siewior <bigeasy-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>, Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>,
	"open list:MEMORY MANAGEMENT" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Luciano Coelho <luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Wang Long <long.wanglong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Richard Fitzgerald <rf-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, open list <linux-kernel@vger.k
To: Viresh Kumar <viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150915141208.GK6350@linux>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

On Tue, Sep 15, 2015 at 07:42:08PM +0530, Viresh Kumar wrote:
> Ah, yes. Thanks for letting me know (I just testedit as well).
> 
> But will it look sane enough to set a boolean to anything apart from
> true/false or 1/0? Yes, it will always be set to 0/1 only, but still..

Let's please not do something unnecessary.  Everybody has different
ideas about what looks natural and the best way to achieve some
semblance of consistency is sticking with minimum unless there are
overriding concerns and there isn't any here.

Thanks.

-- 
tejun
