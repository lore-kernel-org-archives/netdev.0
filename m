From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] net: wireless: rtlwifi: btcoexist: halbtc8821a2ant:
 Remove some unused functions
Date: Sat, 03 Jan 2015 00:05:24 -0600
Message-ID: <54A786A4.2050202@lwfinger.net>
References: <1420230361-1862-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@adurom.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Fengguang Wu <fengguang.wu@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:33120 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbbACGF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jan 2015 01:05:26 -0500
In-Reply-To: <1420230361-1862-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/02/2015 02:26 PM, Rickard Strandqvist wrote:
> Removes some functions that are not used anywhere:
> ex_halbtc8821a2ant_periodical() ex_halbtc8821a2ant_halt_notify()
> ex_halbtc8821a2ant_bt_info_notify()
> ex_halbtc8821a2ant_special_packet_notify()
> ex_halbtc8821a2ant_connect_notify() ex_halbtc8821a2ant_scan_notify()
> ex_halbtc8821a2ant_lps_notify() ex_halbtc8821a2ant_ips_notify()
> ex_halbtc8821a2ant_display_coex_info() ex_halbtc8821a2ant_init_coex_dm()
> ex_halbtc8821a2ant_init_hwconfig()
>
> This was partially found by using a static code analysis program called cppcheck.
>
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

I know that you have been told that including "net: wireless:" in the subject 
line is discouraged. Please do not do this again. The staging directory is 
different as GregKH uses "staging:" in the subject to route patches, but 
wireless does not.

As to the patch, NACK for the simple reason that I am currently working on a 
number of changes to btcoexist. Some of these routines may end up being removed, 
but others will not. Having your patch remove them, and one of mine adding them 
back just constitutes a lot of churning of the source. In addition, it greatly 
increases the probability of the source trees becoming unsynchronized and 
getting merge conflicts.

Larry
