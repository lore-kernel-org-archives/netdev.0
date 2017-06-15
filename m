From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] intel: i40e: virtchnl: fix incorrect
 variable assignment
Date: Thu, 15 Jun 2017 13:50:33 -0700
Message-ID: <20170615135033.00001ecf@intel.com>
References: <20170615023826.GA8136@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        <netdev@vger.kernel.org>, <intel-wired-lan@lists.osuosl.org>,
        <linux-kernel@vger.kernel.org>, jesse.brandeburg@intel.com
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615023826.GA8136@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Jun 2017 21:38:26 -0500
"Gustavo A. R. Silva" <garsilva@embeddedor.com> wrote:

> Fix incorrect variable assignment.
> Based on line 1511: aq_ret = I40_ERR_PARAM; the correct variable to be
> used in this instance is aq_ret instead of ret. Also, variable ret is
> updated at line 1602 just before return, so assigning a value to this
> variable in this code block is useless.
> 
> Addresses-Coverity-ID: 1397693
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Thanks for the fix, looks reasonable.
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
