From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net 2/8] tc/pedit: Extend pedit to specify
 offset relative to mac/transport headers
Date: Mon, 1 May 2017 09:21:13 -0700
Message-ID: <20170501092113.57fd2892@xeon-e3>
References: <20170423125356.1298-1-amir@vadai.me>
        <20170423125356.1298-3-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34741 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933000AbdEAQVQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 12:21:16 -0400
Received: by mail-pg0-f42.google.com with SMTP id v1so46984963pgv.1
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 09:21:16 -0700 (PDT)
In-Reply-To: <20170423125356.1298-3-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Apr 2017 15:53:50 +0300
Amir Vadai <amir@vadai.me> wrote:

> -extern int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type,__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
> -extern int pack_key(struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
> -extern int pack_key32(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
> -extern int pack_key16(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
> -extern int pack_key8(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
> +extern int pack_key(struct m_pedit_sel *sel, struct m_pedit_key *tkey);
> +extern int pack_key32(__u32 retain, struct m_pedit_sel *sel, struct m_pedit_key *tkey);
> +extern int pack_key16(__u32 retain, struct m_pedit_sel *sel, struct m_pedit_key *tkey);
> +extern int pack_key8(__u32 retain, struct m_pedit_sel *sel, struct m_pedit_key *tkey);
>  extern int parse_val(int *argc_p, char ***argv_p, __u32 * val, int type);
> -extern int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type,__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
> -extern int parse_offset(int *argc_p, char ***argv_p,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
> +extern int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type, __u32 retain,
> +		     struct m_pedit_sel *sel, struct m_pedit_key *tkey);
> +extern int parse_offset(int *argc_p, char ***argv_p,
> +			struct m_pedit_sel *sel, struct m_pedit_key *tkey);
>  int parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tc

Please add newline to break the overly long lines here.
Try and keep with in the  80 column convention.
