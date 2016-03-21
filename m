From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 2/2] add devlink tool
Date: Mon, 21 Mar 2016 12:20:40 -0700
Message-ID: <20160321122040.0f0788ff@xeon-e3>
References: <1458053029-7725-1-git-send-email-jiri@resnulli.us>
	<1458053029-7725-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com, hannes@stressinduktion.org,
	gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36471 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757889AbcCUTU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 15:20:26 -0400
Received: by mail-pf0-f174.google.com with SMTP id u190so276953893pfb.3
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2016 12:20:26 -0700 (PDT)
In-Reply-To: <1458053029-7725-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Mar 2016 15:43:49 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Add new tool called devlink which is userspace counterpart of devlink
> Netlink socket.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Lots of checkpatch issues.


ERROR: code indent should use tabs where possible
#509: FILE: devlink/devlink.c:161:
+                return -1;$

WARNING: please, no spaces at the start of a line
#509: FILE: devlink/devlink.c:161:
+                return -1;$

ERROR: open brace '{' following function declarations go on the next line
#854: FILE: devlink/devlink.c:506:
+static void cmd_dev_help(void) {

WARNING: else is not generally useful after a break or return
#911: FILE: devlink/devlink.c:563:
+		return cmd_dev_show(dl);
+	} else {

ERROR: open brace '{' following function declarations go on the next line
#918: FILE: devlink/devlink.c:570:
+static void cmd_port_help(void) {

WARNING: line over 100 characters
#945: FILE: devlink/devlink.c:597:
+			uint16_t des_port_type = mnl_attr_get_u16(tb[DEVLINK_ATTR_PORT_DESIRED_TYPE]);

WARNING: else is not generally useful after a break or return
#1059: FILE: devlink/devlink.c:711:
+		return cmd_port_unsplit(dl);
+	} else {

WARNING: Prefer 'unsigned int' to bare use of 'unsigned'
#1108: FILE: devlink/devlink.c:760:
+	unsigned index = 0;

WARNING: Prefer 'unsigned int' to bare use of 'unsigned'
#1159: FILE: devlink/devlink.c:811:
+	unsigned index = 0;

ERROR: open brace '{' following function declarations go on the next line
#1179: FILE: devlink/devlink.c:831:
+static void cmd_mon_help(void) {

WARNING: else is not generally useful after a break or return
#1192: FILE: devlink/devlink.c:844:
+		return cmd_mon_show(dl);
+	} else {

ERROR: open brace '{' following function declarations go on the next line
#1199: FILE: devlink/devlink.c:851:
+static void help(void) {

WARNING: else is not generally useful after a break or return
#1219: FILE: devlink/devlink.c:871:
+		return cmd_mon(dl);
+	} else {

ERROR: space required before the open parenthesis '('
#1286: FILE: devlink/devlink.c:938:
+		switch(opt) {

ERROR: space required before the open parenthesis '('
#1426: FILE: devlink/mnlg.c:93:
+	switch(type) {

WARNING: 'splitted' may be misspelled - perhaps 'split'?
#1909: FILE: man/man8/devlink-port.8:79:
+.SS devlink port unsplit - unsplit previously splitted devlink port

WARNING: 'splitted' may be misspelled - perhaps 'split'?
#1910: FILE: man/man8/devlink-port.8:80:
+Could be performed on any splitted port of the same split group.

WARNING: 'splitted' may be misspelled - perhaps 'split'?
#1947: FILE: man/man8/devlink-port.8:117:
+Unplit the specified previously splitted devlink port.
