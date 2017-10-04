From: Luciano Coelho <luciano.coelho@intel.com>
Subject: Re: [PATCH 0/3] iwlwifi: cosmetic fixes
Date: Wed, 04 Oct 2017 19:21:08 +0300
Message-ID: <1507134068.908.94.camel@intel.com>
References: <20171004155700.18048-1-christoph@boehmwalder.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Christoph =?ISO-8859-1?Q?B=F6hmwalder?=
        <christoph@boehmwalder.at>, johannes.berg@intel.com,
        emmanuel.grumbach@intel.com, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171004155700.18048-1-christoph@boehmwalder.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-10-04 at 17:56 +0200, Christoph Böhmwalder wrote:
> Fix several code style issues, some of which were reported by
> checkpatch.pl.
> 
> The changes are:
> * One instance of an `int` variable being used in a boolean context,
> chaned to
>   use the more appropriate `bool` type.
> * One very minor fix, removing a newline between a function
> definition and its
>   associated `static` keyword
> * One fix wrapping a macro in curly braces
> 
> 
> Christoph Böhmwalder (3):
>   wireless: iwlwifi: use bool instead of int
>   wireless: iwlwifi: function definition cosmetic fix
>   wireless: iwlwifi: wrap macro into braces
> 
>  drivers/net/wireless/intel/iwlwifi/iwl-io.c     |  2 +-
>  drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c | 16 +++++++------
> ---
>  2 files changed, 8 insertions(+), 10 deletions(-)

Sorry, but this kind of series just generates churn.  Especially when 2
out of 3 patches are broken.  I applied your previous patch because it
was really trivial, but I really don't want to encourage this kind of
drive-by "fixes" that only cause additional work.

I generally only accept this kind of changes when people are changing
code close or related to it.

--
Luca.
