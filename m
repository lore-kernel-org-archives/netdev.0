From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] checkpatch.pl: Fix warnings on (networking specific)
 code comments
Date: Sun, 27 Jan 2013 09:11:07 -0800
Message-ID: <1359306667.14406.7.camel@joe-AO722>
References: <1359286539-18395-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: apw@canonical.com, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359286539-18395-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-01-27 at 03:35 -0800, Jeff Kirsher wrote:
> This patch reverts a portion of the commit to allow multi-line code
> comments to use either style.
[]
> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
[]
> @@ -1878,13 +1878,6 @@ sub process {
>  		}
>  
>  		if ($realfile =~ m@^(drivers/net/|net/)@ &&
> -		    $rawline =~ /^\+[ \t]*\/\*[ \t]*$/ &&
> -		    $prevrawline =~ /^\+[ \t]*$/) {
> -			WARN("NETWORKING_BLOCK_COMMENT_STYLE",
> -			     "networking block comments don't use an empty /* line, use /* Comment...\n" . $hereprev);
> -		}
> -
> -		if ($realfile =~ m@^(drivers/net/|net/)@ &&
>  		    $rawline !~ m@^\+[ \t]*\*/[ \t]*$@ &&	#trailing */
>  		    $rawline !~ m@^\+.*/\*.*\*/[ \t]*$@ &&	#inline /*...*/
>  		    $rawline !~ m@^\+.*\*{2,}/[ \t]*$@ &&	#trailing **/

Shrug.

Ignore things you don't agree with.

David has written many, many emails
requesting changes for this specific
comment style.

I think you and Intel should use
--ignore=NETWORKING_BLOCK_COMMENT_STYLE
to avoid seeing this if you don't agree
with it.

I also think expectations that everyone
will agree with every checkpatch bleat
are unrealistic.
