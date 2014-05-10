From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] checkpatch.pl: Fix checkpatch false positive due to
 ternary operator break
Date: Fri, 09 May 2014 21:47:16 -0700
Message-ID: <1399697236.2912.43.camel@joe-AO725>
References: <1399696911-6550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org,
	David Ertman <davidx.m.ertman@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399696911-6550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-05-09 at 21:41 -0700, Jeff Kirsher wrote:
> From: David Ertman <davidx.m.ertman@intel.com>

Hey David.

> Using the intuitive breaking of a ternary operator used in the
> initialization of a variable in its declaration:
> 
> type var = FOO ?
>            BAR :
>            FEE;
[]
> type var = FOO
>            ? BAR
>            : FEE;
> 
> Change checkpatch so that it is checking fot the correct breaking of ternary
> operators used in networking variable declaration/initialization.

There is no "correct" breaking for ternary operators.
Both should be acceptable.
