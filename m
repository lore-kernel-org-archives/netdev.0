From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH 12/27] ip: iplink_can.c: add json output support
Date: Thu,  3 Aug 2017 17:55:00 +0200
Message-ID: <20170803155515.99226-13-julien@cumulusnetworks.com>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:38008 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751209AbdHCPzt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:55:49 -0400
Received: by mail-wr0-f174.google.com with SMTP id f21so7357448wrf.5
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:55:48 -0700 (PDT)
In-Reply-To: <20170803155515.99226-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema: IFLA_INFO_DATA
{
    "ctrlmode": {
        "type": "array",
        "attr": "IFLA_CAN_CTRLMODE",
        "array": [
            {
                "type": "string"
            }
        ]
    },
    "state": {
        "type": "string",
        "attr": "IFLA_CAN_STATE"
    },
    "berr_counter": {
        "type": "dict",
        "attr": "IFLA_CAN_BERR_COUNTER",
        "dict": {
            "tx": {
                "type": "int"
            },
            "rx": {
                "type": "int"
            }
        }
    },
    "restart_ms": {
        "type": "int",
        "attr": "IFLA_CAN_RESTART_MS"
    },
    "bittiming": {
        "type": "dict",
        "attr": "IFLA_CAN_BITTIMING",
        "dict": {
            "bitrate": {
                "type": "int"
            },
            "sample_point": {
                "type": "float"
            },
            "tq": {
                "type": "int"
            },
            "prop_seg": {
                "type": "int"
            },
            "phase_seg1": {
                "type": "int"
            },
            "phase_seg2": {
                "type": "int"
            },
            "sjw": {
                "type": "int"
            }
        }
    },
    "bittiming_const": {
        "type": "dict",
        "attr": "IFLA_CAN_BITTIMING_CONST",
        "dict": {
            "name": {
                "type": "string"
            },
            "tseg1": {
                "type": "dict",
                "dict": {
                    "min": {
                        "type": "int"
                    },
                    "max": {
                        "type": "int"
                    }
                }
            },
            "tseg2": {
                "type": "dict",
                "dict": {
                    "min": {
                        "type": "int"
                    },
                    "max": {
                        "type": "int"
                    }
                }
            },
            "sjw": {
                "type": "dict",
                "dict": {
                    "min": {
                        "type": "int"
                    },
                    "max": {
                        "type": "int"
                    }
                }
            },
            "brp": {
                "type": "dict",
                "dict": {
                    "min": {
                        "type": "int"
                    },
                    "max": {
                        "type": "int"
                    }
                }
            },
            "brp_inc": {
                "type": "int"
            }
        }
    },
    "bittiming_bitrate": {
        "type": "uint",
        "attr": "IFLA_CAN_BITTIMING"
    },
    "bitrate_const": {
        "type": "array",
        "attr": "IFLA_CAN_BITRATE_CONST",
        "array": [
            {
                "type": "uint"
            }
        ]
    },
    "data_bittiming": {
        "type": "dict",
        "attr": "IFLA_CAN_DATA_BITTIMING",
        "dict": {
            "bitrate": {
                "type": "int"
            },
            "sample_point": {
                "type": "float"
            },
            "tq": {
                "type": "int"
            },
            "prop_seg": {
                "type": "int"
            },
            "phase_seg1": {
                "type": "int"
            },
            "phase_seg2": {
                "type": "int"
            },
            "sjw": {
                "type": "int"
            }
        }
    },
    "data_bittiming_const": {
        "type": "dict",
        "attr": "IFLA_CAN_DATA_BITTIMING_CONST",
        "dict": {
            "name": {
                "type": "string"
            },
            "tseg1": {
                "type": "dict",
                "dict": {
                    "min": {
                        "type": "int"
                    },
                    "max": {
                        "type": "int"
                    }
                }
            },
            "tseg2": {
                "type": "dict",
                "dict": {
                    "min": {
                        "type": "int"
                    },
                    "max": {
                        "type": "int"
                    }
                }
            },
            "sjw": {
                "type": "dict",
                "dict": {
                    "min": {
                        "type": "int"
                    },
                    "max": {
                        "type": "int"
                    }
                }
            },
            "brp": {
                "type": "dict",
                "dict": {
                    "min": {
                        "type": "int"
                    },
                    "max": {
                        "type": "int"
                    }
                }
            },
            "brp_inc": {
                "type": "int"
            }
        }
    },
    "data_bittiming_bitrate": {
        "type": "uint",
        "attr": "IFLA_CAN_DATA_BITTIMING"
    },
    "data_bitrate_const": {
        "type": "array",
        "attr": "IFLA_CAN_DATA_BITRATE_CONST",
        "array": [
            {
                "type": "uint"
            }
        ]
    },
    "termination": {
        "type": "unsigned short",
        "attr": "IFLA_CAN_TERMINATION"
    },
    "termination_const": {
        "type": "array",
        "attr": "IFLA_CAN_TERMINATION_CONST",
        "array": [
            {
                "type": "unsigned short"
            }
        ]
    },
    "clock": {
        "type": "int",
        "attr": "IFLA_CAN_CLOCK"
    }
}

IFLA_INFO_XSTATS
{
    "restarts": {
        "type": "int"
    },
    "bus_error": {
        "type": "int"
    },
    "arbitration_lost": {
        "type": "int"
    },
    "error_warning": {
        "type": "int"
    },
    "error_passive": {
        "type": "int"
    },
    "bus_off": {
        "type": "int"
    }
}

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/iplink_can.c | 276 ++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 208 insertions(+), 68 deletions(-)

diff --git a/ip/iplink_can.c b/ip/iplink_can.c
index 5df56b2b..760fa592 100644
--- a/ip/iplink_can.c
+++ b/ip/iplink_can.c
@@ -89,11 +89,11 @@ static void set_ctrlmode(char *name, char *arg,
 
 static void print_ctrlmode(FILE *f, __u32 cm)
 {
-	fprintf(f, "<");
-#define _PF(cmflag, cmname)					\
-	if (cm & cmflag) {					\
-		cm &= ~cmflag;					\
-		fprintf(f, "%s%s", cmname, cm ? "," : "");	\
+	open_json_array(PRINT_ANY, is_json_context() ? "ctrlmode" : "<");
+#define _PF(cmflag, cmname)						\
+	if (cm & cmflag) {						\
+		cm &= ~cmflag;						\
+		print_string(PRINT_ANY, NULL, cm ? "%s," : "%s", cmname); \
 	}
 	_PF(CAN_CTRLMODE_LOOPBACK, "LOOPBACK");
 	_PF(CAN_CTRLMODE_LISTENONLY, "LISTEN-ONLY");
@@ -105,8 +105,8 @@ static void print_ctrlmode(FILE *f, __u32 cm)
 	_PF(CAN_CTRLMODE_PRESUME_ACK, "PRESUME-ACK");
 #undef _PF
 	if (cm)
-		fprintf(f, "%x", cm);
-	fprintf(f, "> ");
+		print_hex(PRINT_ANY, NULL, "%x", cm);
+	close_json_array(PRINT_ANY, "> ");
 }
 
 static int can_parse_opt(struct link_util *lu, int argc, char **argv,
@@ -260,6 +260,14 @@ static const char *can_state_names[] = {
 	[CAN_STATE_SLEEPING] = "SLEEPING"
 };
 
+static void can_print_json_timing_min_max(const char *attr, int min, int max)
+{
+	open_json_object(attr);
+	print_int(PRINT_JSON, "min", NULL, min);
+	print_int(PRINT_JSON, "max", NULL, max);
+	close_json_object();
+}
+
 static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 {
 	if (!tb)
@@ -275,32 +283,64 @@ static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_CAN_STATE]) {
 		uint32_t state = rta_getattr_u32(tb[IFLA_CAN_STATE]);
 
-		fprintf(f, "state %s ", state <= CAN_STATE_MAX ?
-			can_state_names[state] : "UNKNOWN");
+		if (state <= CAN_STATE_MAX)
+			print_string(PRINT_ANY, "state", "state %s ",
+				     can_state_names[state]);
+		else
+			print_null(PRINT_ANY, "state", "state UNKNOWN", NULL);
 	}
 
 	if (tb[IFLA_CAN_BERR_COUNTER]) {
 		struct can_berr_counter *bc =
 			RTA_DATA(tb[IFLA_CAN_BERR_COUNTER]);
 
-		fprintf(f, "(berr-counter tx %d rx %d) ", bc->txerr, bc->rxerr);
+		if (is_json_context()) {
+			open_json_object("berr_counter");
+			print_int(PRINT_JSON, "tx", NULL, bc->txerr);
+			print_int(PRINT_JSON, "rx", NULL, bc->rxerr);
+			close_json_object();
+		} else {
+			fprintf(f, "(berr-counter tx %d rx %d) ",
+				bc->txerr, bc->rxerr);
+		}
 	}
 
 	if (tb[IFLA_CAN_RESTART_MS]) {
 		__u32 *restart_ms = RTA_DATA(tb[IFLA_CAN_RESTART_MS]);
 
-		fprintf(f, "restart-ms %d ", *restart_ms);
+		print_int(PRINT_ANY,
+			  "restart_ms",
+			  "restart-ms %d ",
+			  *restart_ms);
 	}
 
 	/* bittiming is irrelevant if fixed bitrate is defined */
 	if (tb[IFLA_CAN_BITTIMING] && !tb[IFLA_CAN_BITRATE_CONST]) {
 		struct can_bittiming *bt = RTA_DATA(tb[IFLA_CAN_BITTIMING]);
 
-		fprintf(f, "\n	  bitrate %d sample-point %.3f ",
-			bt->bitrate, (float)bt->sample_point / 1000.);
-		fprintf(f, "\n	  tq %d prop-seg %d phase-seg1 %d phase-seg2 %d sjw %d",
-			bt->tq, bt->prop_seg, bt->phase_seg1, bt->phase_seg2,
-			bt->sjw);
+		if (is_json_context()) {
+			open_json_object("bittiming");
+			print_int(PRINT_ANY, "bitrate", NULL, bt->bitrate);
+			jsonw_float_field_fmt(get_json_writer(),
+					      "sample_point", "%.3f",
+					      (float) bt->sample_point / 1000.);
+			print_int(PRINT_ANY, "tq", NULL, bt->tq);
+			print_int(PRINT_ANY, "prop_seg", NULL, bt->prop_seg);
+			print_int(PRINT_ANY, "phase_seg1",
+				  NULL, bt->phase_seg1);
+			print_int(PRINT_ANY, "phase_seg2",
+				  NULL, bt->phase_seg2);
+			print_int(PRINT_ANY, "sjw", NULL, bt->sjw);
+			close_json_object();
+		} else {
+			fprintf(f, "\n	  bitrate %d sample-point %.3f ",
+				bt->bitrate, (float) bt->sample_point / 1000.);
+			fprintf(f,
+				"\n	  tq %d prop-seg %d phase-seg1 %d phase-seg2 %d sjw %d",
+				bt->tq, bt->prop_seg,
+				bt->phase_seg1, bt->phase_seg2,
+				bt->sjw);
+		}
 	}
 
 	/* bittiming const is irrelevant if fixed bitrate is defined */
@@ -308,17 +348,34 @@ static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		struct can_bittiming_const *btc =
 			RTA_DATA(tb[IFLA_CAN_BITTIMING_CONST]);
 
-		fprintf(f, "\n	  %s: tseg1 %d..%d tseg2 %d..%d "
-			"sjw 1..%d brp %d..%d brp-inc %d",
-			btc->name, btc->tseg1_min, btc->tseg1_max,
-			btc->tseg2_min, btc->tseg2_max, btc->sjw_max,
-			btc->brp_min, btc->brp_max, btc->brp_inc);
+		if (is_json_context()) {
+			open_json_object("bittiming_const");
+			print_string(PRINT_JSON, "name", NULL, btc->name);
+			can_print_json_timing_min_max("tseg1",
+						      btc->tseg1_min,
+						      btc->tseg1_max);
+			can_print_json_timing_min_max("tseg2",
+						      btc->tseg2_min,
+						      btc->tseg2_max);
+			can_print_json_timing_min_max("sjw", 1, btc->sjw_max);
+			can_print_json_timing_min_max("brp",
+						      btc->brp_min,
+						      btc->brp_max);
+			print_int(PRINT_JSON, "brp_inc", NULL, btc->brp_inc);
+			close_json_object();
+		} else {
+			fprintf(f, "\n	  %s: tseg1 %d..%d tseg2 %d..%d "
+				"sjw 1..%d brp %d..%d brp-inc %d",
+				btc->name, btc->tseg1_min, btc->tseg1_max,
+				btc->tseg2_min, btc->tseg2_max, btc->sjw_max,
+				btc->brp_min, btc->brp_max, btc->brp_inc);
+		}
 	}
 
 	if (tb[IFLA_CAN_BITRATE_CONST]) {
 		__u32 *bitrate_const = RTA_DATA(tb[IFLA_CAN_BITRATE_CONST]);
 		int bitrate_cnt = RTA_PAYLOAD(tb[IFLA_CAN_BITRATE_CONST]) /
-				  sizeof(*bitrate_const);
+			sizeof(*bitrate_const);
 		int i;
 		__u32 bitrate = 0;
 
@@ -328,33 +385,62 @@ static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			bitrate = bt->bitrate;
 		}
 
-		fprintf(f, "\n	  bitrate %u", bitrate);
-		fprintf(f, "\n	     [");
+		if (is_json_context()) {
+			print_uint(PRINT_JSON,
+				   "bittiming_bitrate",
+				   NULL, bitrate);
+			open_json_array(PRINT_JSON, "bitrate_const");
+			for (i = 0; i < bitrate_cnt; ++i)
+				print_uint(PRINT_JSON, NULL, NULL,
+					   bitrate_const[i]);
+			close_json_array(PRINT_JSON, NULL);
+		} else {
+			fprintf(f, "\n	  bitrate %u", bitrate);
+			fprintf(f, "\n	     [");
+
+			for (i = 0; i < bitrate_cnt - 1; ++i) {
+				/* This will keep lines below 80 signs */
+				if (!(i % 6) && i)
+					fprintf(f, "\n	      ");
+
+				fprintf(f, "%8u, ", bitrate_const[i]);
+			}
 
-		for (i = 0; i < bitrate_cnt - 1; ++i) {
-			/* This will keep lines below 80 signs */
 			if (!(i % 6) && i)
 				fprintf(f, "\n	      ");
-
-			fprintf(f, "%8u, ", bitrate_const[i]);
+			fprintf(f, "%8u ]", bitrate_const[i]);
 		}
-
-		if (!(i % 6) && i)
-			fprintf(f, "\n	      ");
-		fprintf(f, "%8u ]", bitrate_const[i]);
 	}
 
 	/* data bittiming is irrelevant if fixed bitrate is defined */
 	if (tb[IFLA_CAN_DATA_BITTIMING] && !tb[IFLA_CAN_DATA_BITRATE_CONST]) {
 		struct can_bittiming *dbt =
-			RTA_DATA(tb[IFLA_CAN_DATA_BITTIMING]);
-
-		fprintf(f, "\n	  dbitrate %d dsample-point %.3f ",
-			dbt->bitrate, (float)dbt->sample_point / 1000.);
-		fprintf(f, "\n	  dtq %d dprop-seg %d dphase-seg1 %d "
-			"dphase-seg2 %d dsjw %d",
-			dbt->tq, dbt->prop_seg, dbt->phase_seg1,
-			dbt->phase_seg2, dbt->sjw);
+		    RTA_DATA(tb[IFLA_CAN_DATA_BITTIMING]);
+
+		if (is_json_context()) {
+			open_json_object("data_bittiming");
+			print_int(PRINT_JSON, "bitrate", NULL, dbt->bitrate);
+			jsonw_float_field_fmt(get_json_writer(),
+					      "sample_point",
+					      "%.3f",
+					      (float) dbt->sample_point / 1000.);
+			print_int(PRINT_JSON, "tq", NULL, dbt->tq);
+			print_int(PRINT_JSON, "prop_seg", NULL, dbt->prop_seg);
+			print_int(PRINT_JSON, "phase_seg1",
+				  NULL, dbt->phase_seg1);
+			print_int(PRINT_JSON, "phase_seg2",
+				  NULL, dbt->phase_seg2);
+			print_int(PRINT_JSON, "sjw", NULL, dbt->sjw);
+			close_json_object();
+		} else {
+			fprintf(f, "\n	  dbitrate %d dsample-point %.3f ",
+				dbt->bitrate,
+				(float) dbt->sample_point / 1000.);
+			fprintf(f, "\n	  dtq %d dprop-seg %d dphase-seg1 %d "
+				"dphase-seg2 %d dsjw %d",
+				dbt->tq, dbt->prop_seg, dbt->phase_seg1,
+				dbt->phase_seg2, dbt->sjw);
+		}
 	}
 
 	/* data bittiming const is irrelevant if fixed bitrate is defined */
@@ -363,11 +449,29 @@ static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		struct can_bittiming_const *dbtc =
 			RTA_DATA(tb[IFLA_CAN_DATA_BITTIMING_CONST]);
 
-		fprintf(f, "\n	  %s: dtseg1 %d..%d dtseg2 %d..%d "
-			"dsjw 1..%d dbrp %d..%d dbrp-inc %d",
-			dbtc->name, dbtc->tseg1_min, dbtc->tseg1_max,
-			dbtc->tseg2_min, dbtc->tseg2_max, dbtc->sjw_max,
-			dbtc->brp_min, dbtc->brp_max, dbtc->brp_inc);
+		if (is_json_context()) {
+			open_json_object("data_bittiming_const");
+			print_string(PRINT_JSON, "name", NULL, dbtc->name);
+			can_print_json_timing_min_max("tseg1",
+						      dbtc->tseg1_min,
+						      dbtc->tseg1_max);
+			can_print_json_timing_min_max("tseg2",
+						      dbtc->tseg2_min,
+						      dbtc->tseg2_max);
+			can_print_json_timing_min_max("sjw", 1, dbtc->sjw_max);
+			can_print_json_timing_min_max("brp",
+						      dbtc->brp_min,
+						      dbtc->brp_max);
+
+			print_int(PRINT_JSON, "brp_inc", NULL, dbtc->brp_inc);
+			close_json_object();
+		} else {
+			fprintf(f, "\n	  %s: dtseg1 %d..%d dtseg2 %d..%d "
+				"dsjw 1..%d dbrp %d..%d dbrp-inc %d",
+				dbtc->name, dbtc->tseg1_min, dbtc->tseg1_max,
+				dbtc->tseg2_min, dbtc->tseg2_max, dbtc->sjw_max,
+				dbtc->brp_min, dbtc->brp_max, dbtc->brp_inc);
+		}
 	}
 
 	if (tb[IFLA_CAN_DATA_BITRATE_CONST]) {
@@ -385,41 +489,62 @@ static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			dbitrate = dbt->bitrate;
 		}
 
-		fprintf(f, "\n	  dbitrate %u", dbitrate);
-		fprintf(f, "\n	     [");
+		if (is_json_context()) {
+			print_uint(PRINT_JSON, "data_bittiming_bitrate",
+				   NULL, dbitrate);
+			open_json_array(PRINT_JSON, "data_bitrate_const");
+			for (i = 0; i < dbitrate_cnt; ++i)
+				print_uint(PRINT_JSON, NULL, NULL,
+					   dbitrate_const[i]);
+			close_json_array(PRINT_JSON, NULL);
+		} else {
+			fprintf(f, "\n	  dbitrate %u", dbitrate);
+			fprintf(f, "\n	     [");
+
+			for (i = 0; i < dbitrate_cnt - 1; ++i) {
+				/* This will keep lines below 80 signs */
+				if (!(i % 6) && i)
+					fprintf(f, "\n	      ");
+
+				fprintf(f, "%8u, ", dbitrate_const[i]);
+			}
 
-		for (i = 0; i < dbitrate_cnt - 1; ++i) {
-			/* This will keep lines below 80 signs */
 			if (!(i % 6) && i)
 				fprintf(f, "\n	      ");
-
-			fprintf(f, "%8u, ", dbitrate_const[i]);
+			fprintf(f, "%8u ]", dbitrate_const[i]);
 		}
-
-		if (!(i % 6) && i)
-			fprintf(f, "\n	      ");
-		fprintf(f, "%8u ]", dbitrate_const[i]);
 	}
 
 	if (tb[IFLA_CAN_TERMINATION_CONST] && tb[IFLA_CAN_TERMINATION]) {
 		__u16 *trm = RTA_DATA(tb[IFLA_CAN_TERMINATION]);
 		__u16 *trm_const = RTA_DATA(tb[IFLA_CAN_TERMINATION_CONST]);
 		int trm_cnt = RTA_PAYLOAD(tb[IFLA_CAN_TERMINATION_CONST]) /
-			      sizeof(*trm_const);
+			sizeof(*trm_const);
 		int i;
 
-		fprintf(f, "\n	  termination %hu [ ", *trm);
+		if (is_json_context()) {
+			print_hu(PRINT_JSON, "termination", NULL, *trm);
+			open_json_array(PRINT_JSON, "termination_const");
+			for (i = 0; i < trm_cnt; ++i)
+				print_hu(PRINT_JSON, NULL, NULL, trm_const[i]);
+			close_json_array(PRINT_JSON, NULL);
+		} else {
+			fprintf(f, "\n	  termination %hu [ ", *trm);
 
-		for (i = 0; i < trm_cnt - 1; ++i)
-			fprintf(f, "%hu, ", trm_const[i]);
+			for (i = 0; i < trm_cnt - 1; ++i)
+				fprintf(f, "%hu, ", trm_const[i]);
 
-		fprintf(f, "%hu ]", trm_const[i]);
+			fprintf(f, "%hu ]", trm_const[i]);
+		}
 	}
 
 	if (tb[IFLA_CAN_CLOCK]) {
 		struct can_clock *clock = RTA_DATA(tb[IFLA_CAN_CLOCK]);
 
-		fprintf(f, "\n	  clock %d", clock->freq);
+		print_int(PRINT_ANY,
+			  "clock",
+			  "\n	  clock %d",
+			  clock->freq);
 	}
 
 }
@@ -431,17 +556,32 @@ static void can_print_xstats(struct link_util *lu,
 
 	if (xstats && RTA_PAYLOAD(xstats) == sizeof(*stats)) {
 		stats = RTA_DATA(xstats);
-		fprintf(f, "\n	  re-started bus-errors arbit-lost "
-			"error-warn error-pass bus-off");
-		fprintf(f, "\n	  %-10d %-10d %-10d %-10d %-10d %-10d",
-			stats->restarts, stats->bus_error,
-			stats->arbitration_lost, stats->error_warning,
-			stats->error_passive, stats->bus_off);
+
+		if (is_json_context()) {
+			print_int(PRINT_JSON, "restarts",
+				  NULL, stats->restarts);
+			print_int(PRINT_JSON, "bus_error",
+				  NULL, stats->bus_error);
+			print_int(PRINT_JSON, "arbitration_lost",
+				  NULL, stats->arbitration_lost);
+			print_int(PRINT_JSON, "error_warning",
+				  NULL, stats->error_warning);
+			print_int(PRINT_JSON, "error_passive",
+				  NULL, stats->error_passive);
+			print_int(PRINT_JSON, "bus_off", NULL, stats->bus_off);
+		} else {
+			fprintf(f, "\n	  re-started bus-errors arbit-lost "
+				"error-warn error-pass bus-off");
+			fprintf(f, "\n	  %-10d %-10d %-10d %-10d %-10d %-10d",
+				stats->restarts, stats->bus_error,
+				stats->arbitration_lost, stats->error_warning,
+				stats->error_passive, stats->bus_off);
+		}
 	}
 }
 
 static void can_print_help(struct link_util *lu, int argc, char **argv,
-	FILE *f)
+			   FILE *f)
 {
 	print_usage(f);
 }
-- 
2.13.3
