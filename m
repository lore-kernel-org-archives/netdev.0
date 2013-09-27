From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: RE: [PATCH 08/11] iwlwifi: Remove extern from function prototypes
Date: Fri, 27 Sep 2013 04:25:54 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB301DB4D7E@HASMSX103.ger.corp.intel.com>
References: <cover.1380137609.git.joe@perches.com>
 <b3818394ccdf68d834ca1060c1d5a1fc44e2daee.1380137610.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b3818394ccdf68d834ca1060c1d5a1fc44e2daee.1380137610.git.joe@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Subject: [PATCH 08/11] iwlwifi: Remove extern from function prototypes
> 
> There are a mix of function prototypes with and without extern in the kernel
> sources.  Standardize on not using extern for function prototypes.
> 
> Function prototypes don't need to be written with extern.
> extern is assumed by the compiler.  Its use is as unnecessary as using auto to
> declare automatic/local variables in a block.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/wireless/iwlwifi/dvm/agn.h | 2 +-
> drivers/net/wireless/iwlwifi/dvm/dev.h | 2 +-
> drivers/net/wireless/iwlwifi/dvm/rs.h  | 8 ++++----
> drivers/net/wireless/iwlwifi/mvm/rs.h  | 9 ++++-----
>  4 files changed, 10 insertions(+), 11 deletions(-)
> 

ACK
