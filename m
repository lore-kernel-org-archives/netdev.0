From: Saku Ytti <saku@ytti.fi>
Subject: TCP and reordering
Date: Tue, 27 Nov 2012 11:32:35 +0200
Message-ID: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:63358 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758312Ab2K0Jcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 04:32:36 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so8812554iay.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 01:32:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today due to fast retransmit performance on links which cause
reordering is appalling.

Is it too esoteric situation to handle gracefully? Couldn't we
maintain 'reorder' counter in socket, which is increment when we get
two copies of same packet after duplicate ack, if this counter is
sufficiently high in relation to packet loss, we could start delaying
duplicate acks as we'd expect to receive the sequence very soon.


--
  ++ytti
