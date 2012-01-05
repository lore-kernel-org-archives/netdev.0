From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/7] rtlwifi: Standardize RT_PRINT_DATA macro and uses
Date: Thu, 05 Jan 2012 08:54:44 -0800
Message-ID: <1325782484.22154.25.camel@joe2Laptop>
References: <cover.1325734202.git.joe@perches.com>
	 <e7d4163a9897f33145d8a07be54f507ab68e0243.1325734203.git.joe@perches.com>
	 <20120105114314.GD2222@redhat.com> <1325780947.22154.14.camel@joe2Laptop>
	 <4F05D361.6040809@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F05D361.6040809@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-01-05 at 10:44 -0600, Larry Finger wrote:
> On 01/05/2012 10:29 AM, Joe Perches wrote:
> > It does seem odd though to have a DBG_EMERG and not always
> > emit it.
> Those are always logged, no matter what debug level is set.

Well, not _always_...
	$ echo -1 > /whatever/rtlwifi/debug_level_param
or whatever is appropriate.

cheers, Joe
