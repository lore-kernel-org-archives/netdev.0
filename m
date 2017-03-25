From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH 1/2] net: netfilter: Remove typedef from "typedef struct field_t"
Date: Sat, 25 Mar 2017 17:57:55 +0530
Message-ID: <20170325122756.8743-2-arushisinghal19971997@gmail.com>
References: <20170325122756.8743-1-arushisinghal19971997@gmail.com>
Cc: pablo@netfilter.org, davem@davemloft.net,
        outreachy-kernel@googlegroups.com, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, gregkh@linuxfoundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Arushi Singhal <arushisinghal19971997@gmail.com>
To: kadlec@blackhole.kfki.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33563 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751250AbdCYM2M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 08:28:12 -0400
In-Reply-To: <20170325122756.8743-1-arushisinghal19971997@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes typedefs from struct and renames it from "typedef struct
field_t" to "struct field" as per kernel coding standards."

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 net/netfilter/nf_conntrack_h323_asn1.c | 68 +++++++++++++++++-----------------
 1 file changed, 34 insertions(+), 34 deletions(-)

diff --git a/net/netfilter/nf_conntrack_h323_asn1.c b/net/netfilter/nf_conntrack_h323_asn1.c
index 89b2e46925c4..fb8cf238a76f 100644
--- a/net/netfilter/nf_conntrack_h323_asn1.c
+++ b/net/netfilter/nf_conntrack_h323_asn1.c
@@ -77,7 +77,7 @@
 
 
 /* ASN.1 Field Structure */
-typedef struct field_t {
+struct field {
 #if H323_TRACE
 	char *name;
 #endif
@@ -87,8 +87,8 @@ typedef struct field_t {
 	unsigned char ub;
 	unsigned short attr;
 	unsigned short offset;
-	const struct field_t *fields;
-} field_t;
+	const struct field *fields;
+};
 
 /* Bit Stream */
 typedef struct {
@@ -111,21 +111,21 @@ static unsigned int get_bitmap(bitstr_t *bs, unsigned int b);
 static unsigned int get_uint(bitstr_t *bs, int b);
 
 /* Decoder Functions */
-static int decode_nul(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_bool(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_oid(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_int(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_enum(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_bitstr(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_numstr(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_octstr(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_bmpstr(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_seq(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_seqof(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_choice(bitstr_t *bs, const struct field_t *f, char *base, int level);
+static int decode_nul(bitstr_t *bs, const struct field *f, char *base, int level);
+static int decode_bool(bitstr_t *bs, const struct field *f, char *base, int level);
+static int decode_oid(bitstr_t *bs, const struct field *f, char *base, int level);
+static int decode_int(bitstr_t *bs, const struct field *f, char *base, int level);
+static int decode_enum(bitstr_t *bs, const struct field *f, char *base, int level);
+static int decode_bitstr(bitstr_t *bs, const struct field *f, char *base, int level);
+static int decode_numstr(bitstr_t *bs, const struct field *f, char *base, int level);
+static int decode_octstr(bitstr_t *bs, const struct field *f, char *base, int level);
+static int decode_bmpstr(bitstr_t *bs, const struct field *f, char *base, int level);
+static int decode_seq(bitstr_t *bs, const struct field *f, char *base, int level);
+static int decode_seqof(bitstr_t *bs, const struct field *f, char *base, int level);
+static int decode_choice(bitstr_t *bs, const struct field *f, char *base, int level);
 
 /* Decoder Functions Vector */
-typedef int (*decoder_t)(bitstr_t *, const struct field_t *, char *, int);
+typedef int (*decoder_t)(bitstr_t *, const struct field *, char *, int);
 static const decoder_t Decoders[] = {
 	decode_nul,
 	decode_bool,
@@ -264,7 +264,7 @@ static unsigned int get_uint(bitstr_t *bs, int b)
 }
 
 /****************************************************************************/
-static int decode_nul(bitstr_t *bs, const struct field_t *f,
+static int decode_nul(bitstr_t *bs, const struct field *f,
                       char *base, int level)
 {
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
@@ -273,7 +273,7 @@ static int decode_nul(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_bool(bitstr_t *bs, const struct field_t *f,
+static int decode_bool(bitstr_t *bs, const struct field *f,
                        char *base, int level)
 {
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
@@ -285,7 +285,7 @@ static int decode_bool(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_oid(bitstr_t *bs, const struct field_t *f,
+static int decode_oid(bitstr_t *bs, const struct field *f,
                       char *base, int level)
 {
 	int len;
@@ -302,7 +302,7 @@ static int decode_oid(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_int(bitstr_t *bs, const struct field_t *f,
+static int decode_int(bitstr_t *bs, const struct field *f,
                       char *base, int level)
 {
 	unsigned int len;
@@ -346,7 +346,7 @@ static int decode_int(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_enum(bitstr_t *bs, const struct field_t *f,
+static int decode_enum(bitstr_t *bs, const struct field *f,
                        char *base, int level)
 {
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
@@ -362,7 +362,7 @@ static int decode_enum(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_bitstr(bitstr_t *bs, const struct field_t *f,
+static int decode_bitstr(bitstr_t *bs, const struct field *f,
                          char *base, int level)
 {
 	unsigned int len;
@@ -396,7 +396,7 @@ static int decode_bitstr(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_numstr(bitstr_t *bs, const struct field_t *f,
+static int decode_numstr(bitstr_t *bs, const struct field *f,
                          char *base, int level)
 {
 	unsigned int len;
@@ -414,7 +414,7 @@ static int decode_numstr(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_octstr(bitstr_t *bs, const struct field_t *f,
+static int decode_octstr(bitstr_t *bs, const struct field *f,
                          char *base, int level)
 {
 	unsigned int len;
@@ -463,7 +463,7 @@ static int decode_octstr(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_bmpstr(bitstr_t *bs, const struct field_t *f,
+static int decode_bmpstr(bitstr_t *bs, const struct field *f,
                          char *base, int level)
 {
 	unsigned int len;
@@ -489,12 +489,12 @@ static int decode_bmpstr(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_seq(bitstr_t *bs, const struct field_t *f,
+static int decode_seq(bitstr_t *bs, const struct field *f,
                       char *base, int level)
 {
 	unsigned int ext, bmp, i, opt, len = 0, bmp2, bmp2_len;
 	int err;
-	const struct field_t *son;
+	const struct field *son;
 	unsigned char *beg = NULL;
 
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
@@ -606,12 +606,12 @@ static int decode_seq(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_seqof(bitstr_t *bs, const struct field_t *f,
+static int decode_seqof(bitstr_t *bs, const struct field *f,
                         char *base, int level)
 {
 	unsigned int count, effective_count = 0, i, len = 0;
 	int err;
-	const struct field_t *son;
+	const struct field *son;
 	unsigned char *beg = NULL;
 
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
@@ -696,12 +696,12 @@ static int decode_seqof(bitstr_t *bs, const struct field_t *f,
 
 
 /****************************************************************************/
-static int decode_choice(bitstr_t *bs, const struct field_t *f,
+static int decode_choice(bitstr_t *bs, const struct field *f,
                          char *base, int level)
 {
 	unsigned int type, ext, len = 0;
 	int err;
-	const struct field_t *son;
+	const struct field *son;
 	unsigned char *beg = NULL;
 
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
@@ -768,7 +768,7 @@ static int decode_choice(bitstr_t *bs, const struct field_t *f,
 /****************************************************************************/
 int DecodeRasMessage(unsigned char *buf, size_t sz, RasMessage *ras)
 {
-	static const struct field_t ras_message = {
+	static const struct field ras_message = {
 		FNAME("RasMessage") CHOICE, 5, 24, 32, DECODE | EXT,
 		0, _RasMessage
 	};
@@ -785,7 +785,7 @@ int DecodeRasMessage(unsigned char *buf, size_t sz, RasMessage *ras)
 static int DecodeH323_UserInformation(unsigned char *buf, unsigned char *beg,
 				      size_t sz, H323_UserInformation *uuie)
 {
-	static const struct field_t h323_userinformation = {
+	static const struct field h323_userinformation = {
 		FNAME("H323-UserInformation") SEQ, 1, 2, 2, DECODE | EXT,
 		0, _H323_UserInformation
 	};
@@ -804,7 +804,7 @@ int DecodeMultimediaSystemControlMessage(unsigned char *buf, size_t sz,
 					 MultimediaSystemControlMessage *
 					 mscm)
 {
-	static const struct field_t multimediasystemcontrolmessage = {
+	static const struct field multimediasystemcontrolmessage = {
 		FNAME("MultimediaSystemControlMessage") CHOICE, 2, 4, 4,
 		DECODE | EXT, 0, _MultimediaSystemControlMessage
 	};
-- 
2.11.0
