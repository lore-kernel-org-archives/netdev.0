From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/llc/: misc possible cleanups
Date: Mon, 27 Dec 2004 21:14:17 -0800
Message-ID: <20041227211417.2d077475.davem@davemloft.net>
References: <20041215011211.GC12937@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041215011211.GC12937@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Dec 2004 02:12:11 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> The patch below contains the following possible cleanups:
> - make some needlessly global code static
> - remove the following unused global functions:
>   - lc_c_ac.c: llc_conn_ac_report_status
>   - lc_c_ac.c: llc_conn_ac_send_dm_rsp_f_set_f_flag
>   - lc_c_ac.c: llc_conn_ac_resend_i_cmd_p_set_1
>   - lc_c_ac.c: llc_conn_ac_resend_i_cmd_p_set_1_or_send_rr
>   - lc_c_ac.c: llc_conn_ac_send_ack_cmd_p_set_1
>   - lc_c_ac.c: llc_conn_ac_send_ua_rsp_f_set_f_flag
>   - lc_c_ac.c: llc_conn_ac_set_f_flag_p
>   - llc_c_ev.c: llc_conn_ev_conn_resp
>   - llc_c_ev.c: llc_conn_ev_rst_resp
>   - llc_c_ev.c: llc_conn_ev_rx_xxx_cmd_pbit_set_0
>   - llc_c_ev.c: llc_conn_ev_rx_xxx_yyy
>   - llc_c_ev.c: llc_conn_ev_any_tmr_exp
>   - llc_c_ev.c: llc_conn_ev_qlfy_init_p_f_cycle
>   - llc_c_ev.c: llc_conn_ev_qlfy_set_status_impossible
>   - llc_c_ev.c: llc_conn_ev_qlfy_set_status_received
>   - llc_if.c: llc_build_and_send_reset_pkt
>   - llc_pdu.c: llc_pdu_decode_cr_bit
> - remove the following unneeded EXPORT_SYMBOL:
>   - llc_core.c: llc_sap_list_lock

Also looks good, applied.

Thanks Adrian.
