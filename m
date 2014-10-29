From: Emmanuel Grumbach <egrumbach@gmail.com>
Subject: Re: [patch] iwlwifi: cleanup a mask shift in iwlagn_bt_traffic_is_sco()
Date: Wed, 29 Oct 2014 18:16:18 +0200
Message-ID: <CANUX_P1QCfB5JXptesgzqNtBFjGmzmTxNO=Z6sSZup373w-DAw@mail.gmail.com>
References: <20141029160827.GD5290@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141029160827.GD5290@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 29, 2014 at 6:08 PM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> The shift operation is higher precedence so the code is wrong and it
> sets of a static checker warning.  But it doesn't affect real life
> because BT_UART_MSG_FRAME3SCOESCO_POS is zero so the shift is a no-op.
>
> I have re-written it in normal style and with parenthesis as a cleanup
> and to silence the static checker warning.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>

In my tree already - I got it from Joe.

https://git.kernel.org/cgit/linux/kernel/git/iwlwifi/iwlwifi-next.git/commit/?id=50f6635afe565a0e1c5ab78f040294fe1dc41de0
