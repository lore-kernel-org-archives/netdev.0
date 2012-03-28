From: Li Yu <raise.sail@gmail.com>
Subject: a F-RTO question
Date: Wed, 28 Mar 2012 11:13:49 +0800
Message-ID: <4F7281ED.1060603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:53403 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754619Ab2C1DOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 23:14:00 -0400
Received: by iagz16 with SMTP id z16so831806iag.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 20:13:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

	I have a question about tcp_process_frto(), the below source
code :

static int tcp_process_frto(struct sock *sk, int flag)
{
	.....

        if (!before(tp->snd_una, tp->frto_highmark)) {
                tcp_enter_frto_loss(sk, ...);
                return 1;
        }

	.....

}

	As my understanding, the tp->frto_highmark likes tp->high_seq,
it saves the seqno SND_NXT when a TCP connection enters F-RTO phase,
is it the variable "recovery" in NewReno? So I think that if snd_una is
equal with or after frto_highmark, which means peer ack new data, so
why we enter Loss state here?

	Thanks!

Yu
