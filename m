From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Packet time delays on multi-core systems
Date: Fri, 1 Oct 2010 11:54:08 -0700
Message-ID: <AANLkTi=8_Xi=yV0XxKG9uBnDh0p6ygr1s-8qT9-sVk58@mail.gmail.com>
References: <20100930062419.GD86786@beaver.vrungel.ru>
	<1285828432.5211.812.camel@edumazet-laptop>
	<20100930122321.GA1575@beaver.vrungel.ru>
	<1285850669.2615.426.camel@edumazet-laptop>
	<20100930173732.GB4094@beaver.vrungel.ru>
	<1285869782.2615.920.camel@edumazet-laptop>
	<20100930181556.GC4094@beaver.vrungel.ru>
	<1285872765.2615.1008.camel@edumazet-laptop>
	<20101001101650.GD4094@beaver.vrungel.ru>
	<1285937966.2641.117.camel@edumazet-laptop>
	<20101001141858.GE4094@beaver.vrungel.ru>
	<1285946861.21547.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Vlasov <renton@renton.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Emil Tantilov <emil.s.tantilov@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285946861.21547.24.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 1, 2010 at 08:27, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
> Le vendredi 01 octobre 2010 =C3=A0 18:18 +0400, Alexey Vlasov a =C3=A9=
crit :
>
>> NIC statistics:
>> =C2=A0 =C2=A0 =C2=A0rx_packets: 2973717440
>> =C2=A0 =C2=A0 =C2=A0tx_packets: 3032670910
>> =C2=A0 =C2=A0 =C2=A0rx_bytes: 1892633650741
>> =C2=A0 =C2=A0 =C2=A0tx_bytes: 2536130682695
>> =C2=A0 =C2=A0 =C2=A0rx_broadcast: 118773199
>> =C2=A0 =C2=A0 =C2=A0tx_broadcast: 68013
>> =C2=A0 =C2=A0 =C2=A0rx_multicast: 95257
>> =C2=A0 =C2=A0 =C2=A0tx_multicast: 0
>> =C2=A0 =C2=A0 =C2=A0rx_errors: 0
>> =C2=A0 =C2=A0 =C2=A0tx_errors: 0
>> =C2=A0 =C2=A0 =C2=A0tx_dropped: 0
>> =C2=A0 =C2=A0 =C2=A0multicast: 95257
>> =C2=A0 =C2=A0 =C2=A0collisions: 0
>> =C2=A0 =C2=A0 =C2=A0rx_length_errors: 0
>> =C2=A0 =C2=A0 =C2=A0rx_over_errors: 0
>> =C2=A0 =C2=A0 =C2=A0rx_crc_errors: 0
>> =C2=A0 =C2=A0 =C2=A0rx_frame_errors: 0
>> =C2=A0 =C2=A0 =C2=A0rx_no_buffer_count: 7939
>> =C2=A0 =C2=A0 =C2=A0rx_queue_drop_packet_count: 1324025520
>> =C2=A0 =C2=A0 =C2=A0rx_missed_errors: 146631
>> =C2=A0 =C2=A0 =C2=A0tx_aborted_errors: 0
>> =C2=A0 =C2=A0 =C2=A0tx_carrier_errors: 0
>> =C2=A0 =C2=A0 =C2=A0tx_fifo_errors: 0
>> =C2=A0 =C2=A0 =C2=A0tx_heartbeat_errors: 0
>> =C2=A0 =C2=A0 =C2=A0tx_window_errors: 0
>> =C2=A0 =C2=A0 =C2=A0tx_abort_late_coll: 0
>> =C2=A0 =C2=A0 =C2=A0tx_deferred_ok: 0
>> =C2=A0 =C2=A0 =C2=A0tx_single_coll_ok: 0
>> =C2=A0 =C2=A0 =C2=A0tx_multi_coll_ok: 0
>> =C2=A0 =C2=A0 =C2=A0tx_timeout_count: 0
>> =C2=A0 =C2=A0 =C2=A0tx_restart_queue: 50715
>> =C2=A0 =C2=A0 =C2=A0rx_long_length_errors: 0
>> =C2=A0 =C2=A0 =C2=A0rx_short_length_errors: 0
>> =C2=A0 =C2=A0 =C2=A0rx_align_errors: 0
>> =C2=A0 =C2=A0 =C2=A0tx_tcp_seg_good: 344724062
>> =C2=A0 =C2=A0 =C2=A0tx_tcp_seg_failed: 0
>> =C2=A0 =C2=A0 =C2=A0rx_flow_control_xon: 0
>> =C2=A0 =C2=A0 =C2=A0rx_flow_control_xoff: 0
>> =C2=A0 =C2=A0 =C2=A0tx_flow_control_xon: 0
>> =C2=A0 =C2=A0 =C2=A0tx_flow_control_xoff: 0
>> =C2=A0 =C2=A0 =C2=A0rx_long_byte_count: 1892633650741
>> =C2=A0 =C2=A0 =C2=A0rx_csum_offload_good: 2973697420
>> =C2=A0 =C2=A0 =C2=A0rx_csum_offload_errors: 6235
>> =C2=A0 =C2=A0 =C2=A0tx_dma_out_of_sync: 0
>> =C2=A0 =C2=A0 =C2=A0alloc_rx_buff_failed: 0
>> =C2=A0 =C2=A0 =C2=A0tx_smbus: 9327
>> =C2=A0 =C2=A0 =C2=A0rx_smbus: 118531661
>> =C2=A0 =C2=A0 =C2=A0dropped_smbus: 0
>> =C2=A0 =C2=A0 =C2=A0tx_queue_0_packets: 797617475
>> =C2=A0 =C2=A0 =C2=A0tx_queue_0_bytes: 630191908685
>> =C2=A0 =C2=A0 =C2=A0tx_queue_1_packets: 719681297
>> =C2=A0 =C2=A0 =C2=A0tx_queue_1_bytes: 625907304846
>> =C2=A0 =C2=A0 =C2=A0tx_queue_2_packets: 718841556
>> =C2=A0 =C2=A0 =C2=A0tx_queue_2_bytes: 620522418855
>> =C2=A0 =C2=A0 =C2=A0tx_queue_3_packets: 796521255
>> =C2=A0 =C2=A0 =C2=A0tx_queue_3_bytes: 646196024585
>> =C2=A0 =C2=A0 =C2=A0rx_queue_0_packets: 788885797
>> =C2=A0 =C2=A0 =C2=A0rx_queue_0_bytes: 458936338699
>> =C2=A0 =C2=A0 =C2=A0rx_queue_0_drops: 0
>> =C2=A0 =C2=A0 =C2=A0rx_queue_1_packets: 701354604
>> =C2=A0 =C2=A0 =C2=A0rx_queue_1_bytes: 457490536453
>> =C2=A0 =C2=A0 =C2=A0rx_queue_1_drops: 0
>> =C2=A0 =C2=A0 =C2=A0rx_queue_2_packets: 791887663
>> =C2=A0 =C2=A0 =C2=A0rx_queue_2_bytes: 534425333616
>> =C2=A0 =C2=A0 =C2=A0rx_queue_2_drops: 0
>> =C2=A0 =C2=A0 =C2=A0rx_queue_3_packets: 691579028
>> =C2=A0 =C2=A0 =C2=A0rx_queue_3_bytes: 429887244557
>> =C2=A0 =C2=A0 =C2=A0rx_queue_3_drops: 0
>> 11.111.80: R 1983626201:1983626201(0) win 0
>> > >
>
> OK
>
> IGB stats are wrong... for rx_queue_drop_packet_count field at least
>
> Here is a patch against 2.6.32.23, to get the idea...
>
> Dont trust it unless you patch your kernel ;)
>
> Thanks
>
> Note: current linux-2.6 tree doesnt have this bug.
>
> [PATCH] igb: rx_fifo_errors counter fix
>
> Alexey Vlasov reported insane rx_queue_drop_packet_count
> (rx_fifo_errors) values.
>
> IGB drivers is doing an accumulation for 82575, instead using a zero
> value for rqdpc_total.
>
> Reported-by: Alexey Vlasov <renton@renton.name>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =C2=A0linux-2.6.32.23/net/igb/igb_main.c | =C2=A0 =C2=A05 ++---
> =C2=A01 file changed, 2 insertions(+), 3 deletions(-)
>

Thanks Eric!  I have added the patch to my queue.

--=20
Cheers,
Jeff
