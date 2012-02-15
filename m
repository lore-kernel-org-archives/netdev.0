From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/2] r8169: Enable WOL from Magic Packet by
	default
Date: Wed, 15 Feb 2012 01:13:42 +0100
Message-ID: <20120215001342.GA11453@electric-eye.fr.zoreil.com>
References: <1329244079-27842-1-git-send-email-snanda@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	hayeswang@realtek.com
To: Sameer Nanda <snanda@chromium.org>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1329244079-27842-1-git-send-email-snanda@chromium.org>
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
> Set the WOL config registers to only enable WOL from magic packet by
> default. Without this change in place, the WOL config register
> settings on warm reboot come up in an inconsistent state since these
> registers don't get reset on a warm reboot.

I am not completely convinced, especially as the change of behavior
could be noticed.

Can you elaborate why the previous WoL settings should be ignored ?

-- 
Ueimor
