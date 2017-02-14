From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] sctp: change to use uint<size>_t in uapi sctp.h
Date: Tue, 14 Feb 2017 08:57:09 -0500
Message-ID: <20170214135709.GA14793@hmswarspite.think-freely.org>
References: <05fb9cd9aed85d33cc8d635a18b0dcd3e7c0ff29.1487060628.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38449 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752247AbdBNN6R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 08:58:17 -0500
Content-Disposition: inline
In-Reply-To: <05fb9cd9aed85d33cc8d635a18b0dcd3e7c0ff29.1487060628.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2017 at 04:23:48PM +0800, Xin Long wrote:
> All structures in uapi sctp.h are exported for userspace, their members'
> types should use uint<size>_t instead of __u<size>.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  include/uapi/linux/sctp.h | 398 +++++++++++++++++++++++-----------------------
>  1 file changed, 199 insertions(+), 199 deletions(-)
> 
> diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
> index a91a9cc..a3899a7 100644
> --- a/include/uapi/linux/sctp.h
> +++ b/include/uapi/linux/sctp.h
> @@ -56,7 +56,7 @@
>  #include <linux/types.h>
>  #include <linux/socket.h>
>  
> -typedef __s32 sctp_assoc_t;
> +typedef int32_t sctp_assoc_t;
>  
>  /* The following symbols come from the Sockets API Extensions for
>   * SCTP <draft-ietf-tsvwg-sctpsocket-07.txt>.
> @@ -170,10 +170,10 @@ enum sctp_msg_flags {
>   *   IPPROTO_SCTP  SCTP_INIT      struct sctp_initmsg
>   */
>  struct sctp_initmsg {
> -	__u16 sinit_num_ostreams;
> -	__u16 sinit_max_instreams;
> -	__u16 sinit_max_attempts;
> -	__u16 sinit_max_init_timeo;
> +	uint16_t sinit_num_ostreams;
> +	uint16_t sinit_max_instreams;
> +	uint16_t sinit_max_attempts;
> +	uint16_t sinit_max_init_timeo;
>  };
>  
>  /* 5.3.2 SCTP Header Information Structure (SCTP_SNDRCV)
> @@ -187,14 +187,14 @@ struct sctp_initmsg {
>   *   IPPROTO_SCTP  SCTP_SNDRCV    struct sctp_sndrcvinfo
>   */
>  struct sctp_sndrcvinfo {
> -	__u16 sinfo_stream;
> -	__u16 sinfo_ssn;
> -	__u16 sinfo_flags;
> -	__u32 sinfo_ppid;
> -	__u32 sinfo_context;
> -	__u32 sinfo_timetolive;
> -	__u32 sinfo_tsn;
> -	__u32 sinfo_cumtsn;
> +	uint16_t sinfo_stream;
> +	uint16_t sinfo_ssn;
> +	uint16_t sinfo_flags;
> +	uint32_t sinfo_ppid;
> +	uint32_t sinfo_context;
> +	uint32_t sinfo_timetolive;
> +	uint32_t sinfo_tsn;
> +	uint32_t sinfo_cumtsn;
>  	sctp_assoc_t sinfo_assoc_id;
>  };
>  
> @@ -207,10 +207,10 @@ struct sctp_sndrcvinfo {
>   *   IPPROTO_SCTP  SCTP_SNDINFO   struct sctp_sndinfo
>   */
>  struct sctp_sndinfo {
> -	__u16 snd_sid;
> -	__u16 snd_flags;
> -	__u32 snd_ppid;
> -	__u32 snd_context;
> +	uint16_t snd_sid;
> +	uint16_t snd_flags;
> +	uint32_t snd_ppid;
> +	uint32_t snd_context;
>  	sctp_assoc_t snd_assoc_id;
>  };
>  
> @@ -224,13 +224,13 @@ struct sctp_sndinfo {
>   *   IPPROTO_SCTP  SCTP_RCVINFO   struct sctp_rcvinfo
>   */
>  struct sctp_rcvinfo {
> -	__u16 rcv_sid;
> -	__u16 rcv_ssn;
> -	__u16 rcv_flags;
> -	__u32 rcv_ppid;
> -	__u32 rcv_tsn;
> -	__u32 rcv_cumtsn;
> -	__u32 rcv_context;
> +	uint16_t rcv_sid;
> +	uint16_t rcv_ssn;
> +	uint16_t rcv_flags;
> +	uint32_t rcv_ppid;
> +	uint32_t rcv_tsn;
> +	uint32_t rcv_cumtsn;
> +	uint32_t rcv_context;
>  	sctp_assoc_t rcv_assoc_id;
>  };
>  
> @@ -246,10 +246,10 @@ struct sctp_rcvinfo {
>   *   IPPROTO_SCTP  SCTP_NXTINFO   struct sctp_nxtinfo
>   */
>  struct sctp_nxtinfo {
> -	__u16 nxt_sid;
> -	__u16 nxt_flags;
> -	__u32 nxt_ppid;
> -	__u32 nxt_length;
> +	uint16_t nxt_sid;
> +	uint16_t nxt_flags;
> +	uint32_t nxt_ppid;
> +	uint32_t nxt_length;
>  	sctp_assoc_t nxt_assoc_id;
>  };
>  
> @@ -269,7 +269,7 @@ enum sctp_sinfo_flags {
>  };
>  
>  typedef union {
> -	__u8   			raw;
> +	uint8_t			raw;
>  	struct sctp_initmsg	init;
>  	struct sctp_sndrcvinfo	sndrcv;
>  } sctp_cmsg_data_t;
> @@ -298,15 +298,15 @@ typedef enum sctp_cmsg_type {
>   *
>   */
>  struct sctp_assoc_change {
> -	__u16 sac_type;
> -	__u16 sac_flags;
> -	__u32 sac_length;
> -	__u16 sac_state;
> -	__u16 sac_error;
> -	__u16 sac_outbound_streams;
> -	__u16 sac_inbound_streams;
> +	uint16_t sac_type;
> +	uint16_t sac_flags;
> +	uint32_t sac_length;
> +	uint16_t sac_state;
> +	uint16_t sac_error;
> +	uint16_t sac_outbound_streams;
> +	uint16_t sac_inbound_streams;
>  	sctp_assoc_t sac_assoc_id;
> -	__u8 sac_info[0];
> +	uint8_t sac_info[0];
>  };
>  
>  /*
> @@ -334,12 +334,12 @@ enum sctp_sac_state {
>   *   following structure:
>   */
>  struct sctp_paddr_change {
> -	__u16 spc_type;
> -	__u16 spc_flags;
> -	__u32 spc_length;
> +	uint16_t spc_type;
> +	uint16_t spc_flags;
> +	uint32_t spc_length;
>  	struct sockaddr_storage spc_aaddr;
> -	int spc_state;
> -	int spc_error;
> +	int32_t spc_state;
> +	int32_t spc_error;
>  	sctp_assoc_t spc_assoc_id;
>  } __attribute__((packed, aligned(4)));
>  
> @@ -370,12 +370,12 @@ enum sctp_spc_state {
>   *   error formats. SCTP error TLVs have the format:
>   */
>  struct sctp_remote_error {
> -	__u16 sre_type;
> -	__u16 sre_flags;
> -	__u32 sre_length;
> -	__u16 sre_error;
> +	uint16_t sre_type;
> +	uint16_t sre_flags;
> +	uint32_t sre_length;
> +	uint16_t sre_error;
>  	sctp_assoc_t sre_assoc_id;
> -	__u8 sre_data[0];
> +	uint8_t sre_data[0];
>  };
>  
>  
> @@ -386,13 +386,13 @@ struct sctp_remote_error {
>   *   notification.
>   */
>  struct sctp_send_failed {
> -	__u16 ssf_type;
> -	__u16 ssf_flags;
> -	__u32 ssf_length;
> -	__u32 ssf_error;
> +	uint16_t ssf_type;
> +	uint16_t ssf_flags;
> +	uint32_t ssf_length;
> +	uint32_t ssf_error;
>  	struct sctp_sndrcvinfo ssf_info;
>  	sctp_assoc_t ssf_assoc_id;
> -	__u8 ssf_data[0];
> +	uint8_t ssf_data[0];
>  };
>  
>  /*
> @@ -419,9 +419,9 @@ enum sctp_ssf_flags {
>   *   inform the application that it should cease sending data.
>   */
>  struct sctp_shutdown_event {
> -	__u16 sse_type;
> -	__u16 sse_flags;
> -	__u32 sse_length;
> +	uint16_t sse_type;
> +	uint16_t sse_flags;
> +	uint32_t sse_length;
>  	sctp_assoc_t sse_assoc_id;
>  };
>  
> @@ -433,10 +433,10 @@ struct sctp_shutdown_event {
>   *   that of the peers requested adaptation layer.
>   */
>  struct sctp_adaptation_event {
> -	__u16 sai_type;
> -	__u16 sai_flags;
> -	__u32 sai_length;
> -	__u32 sai_adaptation_ind;
> +	uint16_t sai_type;
> +	uint16_t sai_flags;
> +	uint32_t sai_length;
> +	uint32_t sai_adaptation_ind;
>  	sctp_assoc_t sai_assoc_id;
>  };
>  
> @@ -448,10 +448,10 @@ struct sctp_adaptation_event {
>   *   various events.
>   */
>  struct sctp_pdapi_event {
> -	__u16 pdapi_type;
> -	__u16 pdapi_flags;
> -	__u32 pdapi_length;
> -	__u32 pdapi_indication;
> +	uint16_t pdapi_type;
> +	uint16_t pdapi_flags;
> +	uint32_t pdapi_length;
> +	uint32_t pdapi_indication;
>  	sctp_assoc_t pdapi_assoc_id;
>  };
>  
> @@ -464,12 +464,12 @@ enum { SCTP_PARTIAL_DELIVERY_ABORTED=0, };
>   *  notifications regarding new keys being made active as well as errors.
>   */
>  struct sctp_authkey_event {
> -	__u16 auth_type;
> -	__u16 auth_flags;
> -	__u32 auth_length;
> -	__u16 auth_keynumber;
> -	__u16 auth_altkeynumber;
> -	__u32 auth_indication;
> +	uint16_t auth_type;
> +	uint16_t auth_flags;
> +	uint32_t auth_length;
> +	uint16_t auth_keynumber;
> +	uint16_t auth_altkeynumber;
> +	uint32_t auth_indication;
>  	sctp_assoc_t auth_assoc_id;
>  };
>  
> @@ -484,9 +484,9 @@ enum { SCTP_AUTH_NEWKEY = 0, };
>   * retransmit, the stack will immediately send up this notification.
>   */
>  struct sctp_sender_dry_event {
> -	__u16 sender_dry_type;
> -	__u16 sender_dry_flags;
> -	__u32 sender_dry_length;
> +	uint16_t sender_dry_type;
> +	uint16_t sender_dry_flags;
> +	uint32_t sender_dry_length;
>  	sctp_assoc_t sender_dry_assoc_id;
>  };
>  
> @@ -495,16 +495,16 @@ struct sctp_sender_dry_event {
>   *   Ancillary Data and Notification Interest Options
>   */
>  struct sctp_event_subscribe {
> -	__u8 sctp_data_io_event;
> -	__u8 sctp_association_event;
> -	__u8 sctp_address_event;
> -	__u8 sctp_send_failure_event;
> -	__u8 sctp_peer_error_event;
> -	__u8 sctp_shutdown_event;
> -	__u8 sctp_partial_delivery_event;
> -	__u8 sctp_adaptation_layer_event;
> -	__u8 sctp_authentication_event;
> -	__u8 sctp_sender_dry_event;
> +	uint8_t sctp_data_io_event;
> +	uint8_t sctp_association_event;
> +	uint8_t sctp_address_event;
> +	uint8_t sctp_send_failure_event;
> +	uint8_t sctp_peer_error_event;
> +	uint8_t sctp_shutdown_event;
> +	uint8_t sctp_partial_delivery_event;
> +	uint8_t sctp_adaptation_layer_event;
> +	uint8_t sctp_authentication_event;
> +	uint8_t sctp_sender_dry_event;
>  };
>  
>  /*
> @@ -516,9 +516,9 @@ struct sctp_event_subscribe {
>   */
>  union sctp_notification {
>  	struct {
> -		__u16 sn_type;             /* Notification type. */
> -		__u16 sn_flags;
> -		__u32 sn_length;
> +		uint16_t sn_type;             /* Notification type. */
> +		uint16_t sn_flags;
> +		uint32_t sn_length;
>  	} sn_header;
>  	struct sctp_assoc_change sn_assoc_change;
>  	struct sctp_paddr_change sn_paddr_change;
> @@ -584,9 +584,9 @@ typedef enum sctp_sn_error {
>   */
>  struct sctp_rtoinfo {
>  	sctp_assoc_t	srto_assoc_id;
> -	__u32		srto_initial;
> -	__u32		srto_max;
> -	__u32		srto_min;
> +	uint32_t	srto_initial;
> +	uint32_t	srto_max;
> +	uint32_t	srto_min;
>  };
>  
>  /*
> @@ -597,11 +597,11 @@ struct sctp_rtoinfo {
>   */
>  struct sctp_assocparams {
>  	sctp_assoc_t	sasoc_assoc_id;
> -	__u16		sasoc_asocmaxrxt;
> -	__u16		sasoc_number_peer_destinations;
> -	__u32		sasoc_peer_rwnd;
> -	__u32		sasoc_local_rwnd;
> -	__u32		sasoc_cookie_life;
> +	uint16_t	sasoc_asocmaxrxt;
> +	uint16_t	sasoc_number_peer_destinations;
> +	uint32_t	sasoc_peer_rwnd;
> +	uint32_t	sasoc_local_rwnd;
> +	uint32_t	sasoc_cookie_life;
>  };
>  
>  /*
> @@ -640,7 +640,7 @@ struct sctp_prim {
>   * Indication parameter for all future INIT and INIT-ACK exchanges.
>   */
>  struct sctp_setadaptation {
> -	__u32	ssb_adaptation_ind;
> +	uint32_t	ssb_adaptation_ind;
>  };
>  
>  /*
> @@ -670,11 +670,11 @@ enum  sctp_spp_flags {
>  struct sctp_paddrparams {
>  	sctp_assoc_t		spp_assoc_id;
>  	struct sockaddr_storage	spp_address;
> -	__u32			spp_hbinterval;
> -	__u16			spp_pathmaxrxt;
> -	__u32			spp_pathmtu;
> -	__u32			spp_sackdelay;
> -	__u32			spp_flags;
> +	uint32_t		spp_hbinterval;
> +	uint16_t		spp_pathmaxrxt;
> +	uint32_t		spp_pathmtu;
> +	uint32_t		spp_sackdelay;
> +	uint32_t		spp_flags;
>  } __attribute__((packed, aligned(4)));
>  
>  /*
> @@ -685,7 +685,7 @@ struct sctp_paddrparams {
>   * will only effect future associations on the socket.
>   */
>  struct sctp_authchunk {
> -	__u8		sauth_chunk;
> +	uint8_t		sauth_chunk;
>  };
>  
>  /*
> @@ -705,8 +705,8 @@ enum {
>  #endif
>  
>  struct sctp_hmacalgo {
> -	__u32		shmac_num_idents;
> -	__u16		shmac_idents[];
> +	uint32_t	shmac_num_idents;
> +	uint16_t	shmac_idents[];
>  };
>  
>  /* Sadly, user and kernel space have different names for
> @@ -722,9 +722,9 @@ struct sctp_hmacalgo {
>   */
>  struct sctp_authkey {
>  	sctp_assoc_t	sca_assoc_id;
> -	__u16		sca_keynumber;
> -	__u16		sca_keylength;
> -	__u8		sca_key[];
> +	uint16_t	sca_keynumber;
> +	uint16_t	sca_keylength;
> +	uint8_t		sca_key[];
>  };
>  
>  /*
> @@ -736,7 +736,7 @@ struct sctp_authkey {
>  
>  struct sctp_authkeyid {
>  	sctp_assoc_t	scact_assoc_id;
> -	__u16		scact_keynumber;
> +	uint16_t	scact_keynumber;
>  };
>  
>  
> @@ -777,11 +777,11 @@ struct sctp_assoc_value {
>  struct sctp_paddrinfo {
>  	sctp_assoc_t		spinfo_assoc_id;
>  	struct sockaddr_storage	spinfo_address;
> -	__s32			spinfo_state;
> -	__u32			spinfo_cwnd;
> -	__u32			spinfo_srtt;
> -	__u32			spinfo_rto;
> -	__u32			spinfo_mtu;
> +	int32_t			spinfo_state;
> +	uint32_t		spinfo_cwnd;
> +	uint32_t		spinfo_srtt;
> +	uint32_t		spinfo_rto;
> +	uint32_t		spinfo_mtu;
>  } __attribute__((packed, aligned(4)));
>  
>  /* Peer addresses's state. */
> @@ -812,13 +812,13 @@ enum sctp_spinfo_state {
>   */
>  struct sctp_status {
>  	sctp_assoc_t		sstat_assoc_id;
> -	__s32			sstat_state;
> -	__u32			sstat_rwnd;
> -	__u16			sstat_unackdata;
> -	__u16			sstat_penddata;
> -	__u16			sstat_instrms;
> -	__u16			sstat_outstrms;
> -	__u32			sstat_fragmentation_point;
> +	int32_t			sstat_state;
> +	uint32_t		sstat_rwnd;
> +	uint16_t		sstat_unackdata;
> +	uint16_t		sstat_penddata;
> +	uint16_t		sstat_instrms;
> +	uint16_t		sstat_outstrms;
> +	uint32_t		sstat_fragmentation_point;
>  	struct sctp_paddrinfo	sstat_primary;
>  };
>  
> @@ -831,7 +831,7 @@ struct sctp_status {
>   */
>  struct sctp_authchunks {
>  	sctp_assoc_t	gauth_assoc_id;
> -	__u32		gauth_number_of_chunks;
> +	uint32_t	gauth_number_of_chunks;
>  	uint8_t		gauth_chunks[];
>  };
>  
> @@ -861,7 +861,7 @@ enum sctp_sstat_state {
>   * the SCTP associations handled by a one-to-many style socket.
>   */
>  struct sctp_assoc_ids {
> -	__u32		gaids_number_of_ids;
> +	uint32_t	gaids_number_of_ids;
>  	sctp_assoc_t	gaids_assoc_id[];
>  };
>  
> @@ -883,8 +883,8 @@ struct sctp_getaddrs_old {
>  
>  struct sctp_getaddrs {
>  	sctp_assoc_t		assoc_id; /*input*/
> -	__u32			addr_num; /*output*/
> -	__u8			addrs[0]; /*output, variable size*/
> +	uint32_t		addr_num; /*output*/
> +	uint8_t			addrs[0]; /*output, variable size*/
>  };
>  
>  /* A socket user request obtained via SCTP_GET_ASSOC_STATS that retrieves
> @@ -896,21 +896,21 @@ struct sctp_assoc_stats {
>  	sctp_assoc_t	sas_assoc_id;    /* Input */
>  					 /* Transport of observed max RTO */
>  	struct sockaddr_storage sas_obs_rto_ipaddr;
> -	__u64		sas_maxrto;      /* Maximum Observed RTO for period */
> -	__u64		sas_isacks;	 /* SACKs received */
> -	__u64		sas_osacks;	 /* SACKs sent */
> -	__u64		sas_opackets;	 /* Packets sent */
> -	__u64		sas_ipackets;	 /* Packets received */
> -	__u64		sas_rtxchunks;   /* Retransmitted Chunks */
> -	__u64		sas_outofseqtsns;/* TSN received > next expected */
> -	__u64		sas_idupchunks;  /* Dups received (ordered+unordered) */
> -	__u64		sas_gapcnt;      /* Gap Acknowledgements Received */
> -	__u64		sas_ouodchunks;  /* Unordered data chunks sent */
> -	__u64		sas_iuodchunks;  /* Unordered data chunks received */
> -	__u64		sas_oodchunks;	 /* Ordered data chunks sent */
> -	__u64		sas_iodchunks;	 /* Ordered data chunks received */
> -	__u64		sas_octrlchunks; /* Control chunks sent */
> -	__u64		sas_ictrlchunks; /* Control chunks received */
> +	uint64_t	sas_maxrto;      /* Maximum Observed RTO for period */
> +	uint64_t	sas_isacks;	 /* SACKs received */
> +	uint64_t	sas_osacks;	 /* SACKs sent */
> +	uint64_t	sas_opackets;	 /* Packets sent */
> +	uint64_t	sas_ipackets;	 /* Packets received */
> +	uint64_t	sas_rtxchunks;   /* Retransmitted Chunks */
> +	uint64_t	sas_outofseqtsns;/* TSN received > next expected */
> +	uint64_t	sas_idupchunks;  /* Dups received (ordered+unordered) */
> +	uint64_t	sas_gapcnt;      /* Gap Acknowledgements Received */
> +	uint64_t	sas_ouodchunks;  /* Unordered data chunks sent */
> +	uint64_t	sas_iuodchunks;  /* Unordered data chunks received */
> +	uint64_t	sas_oodchunks;	 /* Ordered data chunks sent */
> +	uint64_t	sas_iodchunks;	 /* Ordered data chunks received */
> +	uint64_t	sas_octrlchunks; /* Control chunks sent */
> +	uint64_t	sas_ictrlchunks; /* Control chunks received */
>  };
>  
>  /*
> @@ -936,8 +936,8 @@ typedef struct {
>  struct sctp_paddrthlds {
>  	sctp_assoc_t spt_assoc_id;
>  	struct sockaddr_storage spt_address;
> -	__u16 spt_pathmaxrxt;
> -	__u16 spt_pathpfthld;
> +	uint16_t spt_pathmaxrxt;
> +	uint16_t spt_pathpfthld;
>  };
>  
>  /*
> @@ -945,80 +945,80 @@ struct sctp_paddrthlds {
>   */
>  struct sctp_prstatus {
>  	sctp_assoc_t sprstat_assoc_id;
> -	__u16 sprstat_sid;
> -	__u16 sprstat_policy;
> -	__u64 sprstat_abandoned_unsent;
> -	__u64 sprstat_abandoned_sent;
> +	uint16_t sprstat_sid;
> +	uint16_t sprstat_policy;
> +	uint64_t sprstat_abandoned_unsent;
> +	uint64_t sprstat_abandoned_sent;
>  };
>  
>  struct sctp_default_prinfo {
>  	sctp_assoc_t pr_assoc_id;
> -	__u32 pr_value;
> -	__u16 pr_policy;
> +	uint32_t pr_value;
> +	uint16_t pr_policy;
>  };
>  
>  struct sctp_info {
> -	__u32	sctpi_tag;
> -	__u32	sctpi_state;
> -	__u32	sctpi_rwnd;
> -	__u16	sctpi_unackdata;
> -	__u16	sctpi_penddata;
> -	__u16	sctpi_instrms;
> -	__u16	sctpi_outstrms;
> -	__u32	sctpi_fragmentation_point;
> -	__u32	sctpi_inqueue;
> -	__u32	sctpi_outqueue;
> -	__u32	sctpi_overall_error;
> -	__u32	sctpi_max_burst;
> -	__u32	sctpi_maxseg;
> -	__u32	sctpi_peer_rwnd;
> -	__u32	sctpi_peer_tag;
> -	__u8	sctpi_peer_capable;
> -	__u8	sctpi_peer_sack;
> -	__u16	__reserved1;
> +	uint32_t	sctpi_tag;
> +	uint32_t	sctpi_state;
> +	uint32_t	sctpi_rwnd;
> +	uint16_t	sctpi_unackdata;
> +	uint16_t	sctpi_penddata;
> +	uint16_t	sctpi_instrms;
> +	uint16_t	sctpi_outstrms;
> +	uint32_t	sctpi_fragmentation_point;
> +	uint32_t	sctpi_inqueue;
> +	uint32_t	sctpi_outqueue;
> +	uint32_t	sctpi_overall_error;
> +	uint32_t	sctpi_max_burst;
> +	uint32_t	sctpi_maxseg;
> +	uint32_t	sctpi_peer_rwnd;
> +	uint32_t	sctpi_peer_tag;
> +	uint8_t		sctpi_peer_capable;
> +	uint8_t		sctpi_peer_sack;
> +	uint16_t	__reserved1;
>  
>  	/* assoc status info */
> -	__u64	sctpi_isacks;
> -	__u64	sctpi_osacks;
> -	__u64	sctpi_opackets;
> -	__u64	sctpi_ipackets;
> -	__u64	sctpi_rtxchunks;
> -	__u64	sctpi_outofseqtsns;
> -	__u64	sctpi_idupchunks;
> -	__u64	sctpi_gapcnt;
> -	__u64	sctpi_ouodchunks;
> -	__u64	sctpi_iuodchunks;
> -	__u64	sctpi_oodchunks;
> -	__u64	sctpi_iodchunks;
> -	__u64	sctpi_octrlchunks;
> -	__u64	sctpi_ictrlchunks;
> +	uint64_t	sctpi_isacks;
> +	uint64_t	sctpi_osacks;
> +	uint64_t	sctpi_opackets;
> +	uint64_t	sctpi_ipackets;
> +	uint64_t	sctpi_rtxchunks;
> +	uint64_t	sctpi_outofseqtsns;
> +	uint64_t	sctpi_idupchunks;
> +	uint64_t	sctpi_gapcnt;
> +	uint64_t	sctpi_ouodchunks;
> +	uint64_t	sctpi_iuodchunks;
> +	uint64_t	sctpi_oodchunks;
> +	uint64_t	sctpi_iodchunks;
> +	uint64_t	sctpi_octrlchunks;
> +	uint64_t	sctpi_ictrlchunks;
>  
>  	/* primary transport info */
>  	struct sockaddr_storage	sctpi_p_address;
> -	__s32	sctpi_p_state;
> -	__u32	sctpi_p_cwnd;
> -	__u32	sctpi_p_srtt;
> -	__u32	sctpi_p_rto;
> -	__u32	sctpi_p_hbinterval;
> -	__u32	sctpi_p_pathmaxrxt;
> -	__u32	sctpi_p_sackdelay;
> -	__u32	sctpi_p_sackfreq;
> -	__u32	sctpi_p_ssthresh;
> -	__u32	sctpi_p_partial_bytes_acked;
> -	__u32	sctpi_p_flight_size;
> -	__u16	sctpi_p_error;
> -	__u16	__reserved2;
> +	int32_t		sctpi_p_state;
> +	uint32_t	sctpi_p_cwnd;
> +	uint32_t	sctpi_p_srtt;
> +	uint32_t	sctpi_p_rto;
> +	uint32_t	sctpi_p_hbinterval;
> +	uint32_t	sctpi_p_pathmaxrxt;
> +	uint32_t	sctpi_p_sackdelay;
> +	uint32_t	sctpi_p_sackfreq;
> +	uint32_t	sctpi_p_ssthresh;
> +	uint32_t	sctpi_p_partial_bytes_acked;
> +	uint32_t	sctpi_p_flight_size;
> +	uint16_t	sctpi_p_error;
> +	uint16_t	__reserved2;
>  
>  	/* sctp sock info */
> -	__u32	sctpi_s_autoclose;
> -	__u32	sctpi_s_adaptation_ind;
> -	__u32	sctpi_s_pd_point;
> -	__u8	sctpi_s_nodelay;
> -	__u8	sctpi_s_disable_fragments;
> -	__u8	sctpi_s_v4mapped;
> -	__u8	sctpi_s_frag_interleave;
> -	__u32	sctpi_s_type;
> -	__u32	__reserved3;
> +	uint32_t	sctpi_s_autoclose;
> +	uint32_t	sctpi_s_adaptation_ind;
> +	uint32_t	sctpi_s_pd_point;
> +	uint8_t		sctpi_s_nodelay;
> +	uint8_t		sctpi_s_disable_fragments;
> +	uint8_t		sctpi_s_v4mapped;
> +	uint8_t		sctpi_s_frag_interleave;
> +	uint32_t	sctpi_s_type;
> +	uint32_t	__reserved3;
>  };
>  
>  struct sctp_reset_streams {
> -- 
> 2.1.0
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
