From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 driver and samba
Date: Fri, 14 Sep 2007 13:59:48 -0700
Message-ID: <46EAF644.1040006@intel.com>
References: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>	 <46EAC25B.2060404@intel.com> <780b6f780709141140l1fd586c9p2aa8efe6ed803d38@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
To: L F <lfabio.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11236 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752482AbXINU7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 16:59:51 -0400
In-Reply-To: <780b6f780709141140l1fd586c9p2aa8efe6ed803d38@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

L F wrote:
> On 9/14/07, Kok, Auke <auke-jan.h.kok@intel.com> wrote:
>> this slowness might have been masking the issue
> That is possible. However, it worked for upwards of twelve months
> without an error.
> 
>> I have not yet seen other reports of this issue, and it would be interesting to
>> see if the stack or driver is seeing errors. Please post `ethtool -S eth0` after
>> the samba connection resets or fails.
> If you look for it on the Realtek cards, there had been sporadic
> issues up to late 2005. The solution posted universally was 'change
> card'.
> 
> I include the content of ethtool -S as requested:
> beehive:~# ethtool -S eth4
> NIC statistics:
>      rx_packets: 43538709
>      tx_packets: 68726231
>      rx_bytes: 34124849453
>      tx_bytes: 74817483835
>      rx_broadcast: 20891
>      tx_broadcast: 8941
>      rx_multicast: 459
>      tx_multicast: 0
>      rx_errors: 0
>      tx_errors: 0
>      tx_dropped: 0
>      multicast: 459
>      collisions: 0
>      rx_length_errors: 0
>      rx_over_errors: 0
>      rx_crc_errors: 0
>      rx_frame_errors: 0
>      rx_no_buffer_count: 0
>      rx_missed_errors: 0
>      tx_aborted_errors: 0
>      tx_carrier_errors: 0
>      tx_fifo_errors: 0
>      tx_heartbeat_errors: 0
>      tx_window_errors: 0
>      tx_abort_late_coll: 0
>      tx_deferred_ok: 486
>      tx_single_coll_ok: 0
>      tx_multi_coll_ok: 0
>      tx_timeout_count: 0
>      tx_restart_queue: 0
>      rx_long_length_errors: 0
>      rx_short_length_errors: 0
>      rx_align_errors: 0
>      tx_tcp_seg_good: 0
>      tx_tcp_seg_failed: 0
>      rx_flow_control_xon: 488
>      rx_flow_control_xoff: 488
>      tx_flow_control_xon: 0
>      tx_flow_control_xoff: 0
>      rx_long_byte_count: 34124849453
>      rx_csum_offload_good: 43449333
>      rx_csum_offload_errors: 0
>      rx_header_split: 0
>      alloc_rx_buff_failed: 0
>      tx_smbus: 0
>      rx_smbus: 0
>      dropped_smbus: 0
> 
> I am no expert, but I do not see anything that obviously points to an
> issue there.
> Now, something I did not mention before, though it was clearly evident
> from context, is that the errors ONLY occur on samba WRITE. I can read
> hundreds of GBs of data without error.

can you describe your setup a bit more in detail? you're writing from a linux 
client to a windows smb server? or even to a linux server? which end sees the 
connection drop? the samba server? the samba linux client?

Auke
