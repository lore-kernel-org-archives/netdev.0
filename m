From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/2] r8169: transition to D0 state at shutdown
Date: Wed, 15 Feb 2012 01:14:53 +0100
Message-ID: <20120215001453.GB11453@electric-eye.fr.zoreil.com>
References: <1329244275-28130-1-git-send-email-snanda@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	hayeswang@realtek.com
To: Sameer Nanda <snanda@chromium.org>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1329244275-28130-1-git-send-email-snanda@chromium.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/linux-pm/>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Sameer Nanda <snanda@chromium.org> :
> With runtime PM, if the ethernet cable is disconnected, the device is
> transitioned to D3 state to conserve energy. If the system is shutdown
> in this state, any register accesses in rtl_shutdown are dropped on
> the floor.
> 
> This patch transitions the device back to D0 state in rtl_shutdown if
> the device was runtime PM suspended. In addition, since runtiome PM
> also mucks around with WOL options, the saved WOL options are also
> restored in rtl_shutdown.

Ok.

I'll leave Rafael choose if he prefers the runtime pm layer to handle it
or not.

-- 
Ueimor
