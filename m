From: akpm@osdl.org
Subject: [patch 16/18] gcc-3.5: sctp
Date: Sun, 25 Jan 2004 03:08:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251108.i0PB8Fo25134@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



In file included from include/net/sctp/structs.h:65,
                 from include/net/sctp/sctp.h:91,
                 from net/sctp/sm_statetable.c:49:
include/linux/sctp.h:64: warning: `packed' attribute ignored
include/linux/sctp.h:71: warning: `packed' attribute ignored
include/linux/sctp.h:155: warning: `packed' attribute ignored
include/linux/sctp.h:205: warning: `packed' attribute ignored
include/linux/sctp.h:210: warning: `packed' attribute ignored
include/linux/sctp.h:235: warning: `packed' attribute ignored
include/linux/sctp.h:240: warning: `packed' attribute ignored
include/linux/sctp.h:247: warning: `packed' attribute ignored
include/linux/sctp.h:253: warning: `packed' attribute ignored
include/linux/sctp.h:259: warning: `packed' attribute ignored
include/linux/sctp.h:265: warning: `packed' attribute ignored
include/linux/sctp.h:271: warning: `packed' attribute ignored
include/linux/sctp.h:276: warning: `packed' attribute ignored
include/linux/sctp.h:290: warning: `packed' attribute ignored
include/linux/sctp.h:296: warning: `packed' attribute ignored
include/linux/sctp.h:311: warning: `packed' attribute ignored
include/linux/sctp.h:326: warning: `packed' attribute ignored
include/linux/sctp.h:331: warning: `packed' attribute ignored
include/linux/sctp.h:343: warning: `packed' attribute ignored
include/linux/sctp.h:348: warning: `packed' attribute ignored
include/linux/sctp.h:357: warning: `packed' attribute ignored
include/linux/sctp.h:365: warning: `packed' attribute ignored
include/linux/sctp.h:380: warning: `packed' attribute ignored
include/linux/sctp.h:385: warning: `packed' attribute ignored
include/linux/sctp.h:463: warning: `packed' attribute ignored
include/linux/sctp.h:475: warning: `packed' attribute ignored
include/linux/sctp.h:516: warning: `packed' attribute ignored
include/linux/sctp.h:521: warning: `packed' attribute ignored
include/linux/sctp.h:526: warning: `packed' attribute ignored
In file included from include/net/sctp/sctp.h:91,
                 from net/sctp/sm_statetable.c:49:
include/net/sctp/structs.h:372: warning: `packed' attribute ignored



---

 include/linux/sctp.h       |   62 +++++++++++++++++++++------------------------
 include/net/sctp/structs.h |    2 -
 2 files changed, 31 insertions(+), 33 deletions(-)

diff -puN include/linux/sctp.h~gcc-35-sctp-attribute_packed-fix include/linux/sctp.h
--- 25/include/linux/sctp.h~gcc-35-sctp-attribute_packed-fix	2004-01-24 00:11:36.000000000 -0800
+++ 25-akpm/include/linux/sctp.h	2004-01-24 00:11:36.000000000 -0800
@@ -61,14 +61,14 @@ typedef struct sctphdr {
 	__u16 dest;
 	__u32 vtag;
 	__u32 checksum;
-} sctp_sctphdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_sctphdr_t;
 
 /* Section 3.2.  Chunk Field Descriptions. */
 typedef struct sctp_chunkhdr {
 	__u8 type;
 	__u8 flags;
 	__u16 length;
-} sctp_chunkhdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_chunkhdr_t;
 
 
 /* Section 3.2.  Chunk Type Values.
@@ -152,7 +152,7 @@ enum { SCTP_CHUNK_FLAG_T = 0x01 };
 typedef struct sctp_paramhdr {
 	__u16 type;
 	__u16 length;
-} sctp_paramhdr_t __attribute((packed));
+} __attribute__((packed)) sctp_paramhdr_t;
 
 typedef enum {
 
@@ -202,12 +202,12 @@ typedef struct sctp_datahdr {
 	__u16 ssn;
 	__u32 ppid;
 	__u8  payload[0];
-} sctp_datahdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_datahdr_t;
 
 typedef struct sctp_data_chunk {
         sctp_chunkhdr_t chunk_hdr;
         sctp_datahdr_t  data_hdr;
-} sctp_data_chunk_t __attribute__((packed));
+} __attribute__((packed)) sctp_data_chunk_t;
 
 /* DATA Chuck Specific Flags */
 enum {
@@ -232,48 +232,48 @@ typedef struct sctp_inithdr {
 	__u16 num_inbound_streams;
 	__u32 initial_tsn;
 	__u8  params[0];
-} sctp_inithdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_inithdr_t;
 
 typedef struct sctp_init_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_inithdr_t init_hdr;
-} sctp_init_chunk_t __attribute__((packed));
+} __attribute__((packed)) sctp_init_chunk_t;
 
 
 /* Section 3.3.2.1. IPv4 Address Parameter (5) */
 typedef struct sctp_ipv4addr_param {
 	sctp_paramhdr_t param_hdr;
 	struct in_addr  addr;
-} sctp_ipv4addr_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_ipv4addr_param_t;
 
 /* Section 3.3.2.1. IPv6 Address Parameter (6) */
 typedef struct sctp_ipv6addr_param {
 	sctp_paramhdr_t param_hdr;
 	struct in6_addr addr;
-} sctp_ipv6addr_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_ipv6addr_param_t;
 
 /* Section 3.3.2.1 Cookie Preservative (9) */
 typedef struct sctp_cookie_preserve_param {
 	sctp_paramhdr_t param_hdr;
 	uint32_t        lifespan_increment;
-} sctp_cookie_preserve_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_cookie_preserve_param_t;
 
 /* Section 3.3.2.1 Host Name Address (11) */
 typedef struct sctp_hostname_param {
 	sctp_paramhdr_t param_hdr;
 	uint8_t hostname[0];
-} sctp_hostname_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_hostname_param_t;
 
 /* Section 3.3.2.1 Supported Address Types (12) */
 typedef struct sctp_supported_addrs_param {
 	sctp_paramhdr_t param_hdr;
 	uint16_t types[0];
-} sctp_supported_addrs_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_supported_addrs_param_t;
 
 /* Appendix A. ECN Capable (32768) */
 typedef struct sctp_ecn_capable_param {
 	sctp_paramhdr_t param_hdr;
-} sctp_ecn_capable_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_ecn_capable_param_t;
 
 
 
@@ -287,13 +287,13 @@ typedef sctp_init_chunk_t sctp_initack_c
 typedef struct sctp_cookie_param {
 	sctp_paramhdr_t p;
 	__u8 body[0];
-} sctp_cookie_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_cookie_param_t;
 
 /* Section 3.3.3.1 Unrecognized Parameters (8) */
 typedef struct sctp_unrecognized_param {
 	sctp_paramhdr_t param_hdr;
 	sctp_paramhdr_t unrecognized;
-} sctp_unrecognized_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_unrecognized_param_t;
 
 
 
@@ -308,7 +308,7 @@ typedef struct sctp_unrecognized_param {
 typedef struct sctp_gap_ack_block {
 	__u16 start;
 	__u16 end;
-} sctp_gap_ack_block_t __attribute__((packed));
+} __attribute__((packed)) sctp_gap_ack_block_t;
 
 typedef uint32_t sctp_dup_tsn_t;
 
@@ -323,12 +323,12 @@ typedef struct sctp_sackhdr {
 	__u16 num_gap_ack_blocks;
 	__u16 num_dup_tsns;
 	sctp_sack_variable_t variable[0];
-} sctp_sackhdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_sackhdr_t;
 
 typedef struct sctp_sack_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_sackhdr_t sack_hdr;
-} sctp_sack_chunk_t __attribute__((packed));
+} __attribute__((packed)) sctp_sack_chunk_t;
 
 
 /* RFC 2960.  Section 3.3.5 Heartbeat Request (HEARTBEAT) (4):
@@ -340,12 +340,12 @@ typedef struct sctp_sack_chunk {
 
 typedef struct sctp_heartbeathdr {
 	sctp_paramhdr_t info;
-} sctp_heartbeathdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_heartbeathdr_t;
 
 typedef struct sctp_heartbeat_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_heartbeathdr_t hb_hdr;
-} sctp_heartbeat_chunk_t __attribute__((packed));
+} __attribute__((packed)) sctp_heartbeat_chunk_t;
 
 
 /* For the abort and shutdown ACK we must carry the init tag in the
@@ -354,7 +354,7 @@ typedef struct sctp_heartbeat_chunk {
  */
 typedef struct sctp_abort_chunk {
         sctp_chunkhdr_t uh;
-} sctp_abort_chunkt_t __attribute__((packed));
+} __attribute__((packed)) sctp_abort_chunkt_t;
 
 
 /* For the graceful shutdown we must carry the tag (in common header)
@@ -362,14 +362,12 @@ typedef struct sctp_abort_chunk {
  */
 typedef struct sctp_shutdownhdr {
 	__u32 cum_tsn_ack;
-} sctp_shutdownhdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_shutdownhdr_t;
 
 struct sctp_shutdown_chunk_t {
         sctp_chunkhdr_t    chunk_hdr;
         sctp_shutdownhdr_t shutdown_hdr;
-} __attribute__((packed));
-
-
+} __attribute__ ((packed));
 
 /* RFC 2960.  Section 3.3.10 Operation Error (ERROR) (9) */
 
@@ -377,12 +375,12 @@ typedef struct sctp_errhdr {
 	__u16 cause;
 	__u16 length;
 	__u8  variable[0];
-} sctp_errhdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_errhdr_t;
 
 typedef struct sctp_operr_chunk {
         sctp_chunkhdr_t chunk_hdr;
 	sctp_errhdr_t   err_hdr;
-} sctp_operr_chunk_t __attribute__((packed));
+} __attribute__((packed)) sctp_operr_chunk_t;
 
 /* RFC 2960 3.3.10 - Operation Error
  *
@@ -460,7 +458,7 @@ typedef struct sctp_ecnehdr {
 typedef struct sctp_ecne_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_ecnehdr_t ence_hdr;
-} sctp_ecne_chunk_t __attribute__((packed));
+} __attribute__((packed)) sctp_ecne_chunk_t;
 
 /* RFC 2960.  Appendix A.  Explicit Congestion Notification.
  *   Congestion Window Reduced (CWR) (13)
@@ -472,7 +470,7 @@ typedef struct sctp_cwrhdr {
 typedef struct sctp_cwr_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_cwrhdr_t cwr_hdr;
-} sctp_cwr_chunk_t __attribute__((packed));
+} __attribute__((packed)) sctp_cwr_chunk_t;
 
 /*
  * ADDIP Section 3.1 New Chunk Types
@@ -513,16 +511,16 @@ typedef struct sctp_cwr_chunk {
 typedef struct sctp_addip_param {
 	sctp_paramhdr_t	param_hdr;
 	__u32		crr_id;	
-}sctp_addip_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_addip_param_t;
 
 typedef struct sctp_addiphdr {
 	__u32	serial;
 	__u8	params[0];
-} sctp_addiphdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_addiphdr_t;
 
 typedef struct sctp_addip_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_addiphdr_t addip_hdr;
-} sctp_addip_chunk_t __attribute__((packed));
+} __attribute__((packed)) sctp_addip_chunk_t;
 
 #endif /* __LINUX_SCTP_H__ */
diff -puN include/net/sctp/structs.h~gcc-35-sctp-attribute_packed-fix include/net/sctp/structs.h
--- 25/include/net/sctp/structs.h~gcc-35-sctp-attribute_packed-fix	2004-01-24 00:11:36.000000000 -0800
+++ 25-akpm/include/net/sctp/structs.h	2004-01-24 00:11:36.000000000 -0800
@@ -369,7 +369,7 @@ typedef struct sctp_sender_hb_info {
 	struct sctp_paramhdr param_hdr;
 	union sctp_addr daddr;
 	unsigned long sent_at;
-} sctp_sender_hb_info_t __attribute__((packed));
+} __attribute__((packed)) sctp_sender_hb_info_t;
 
 /*
  *  RFC 2960 1.3.2 Sequenced Delivery within Streams

_
