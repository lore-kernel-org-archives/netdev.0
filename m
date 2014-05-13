From: Achal Verma <achalv18@gmail.com>
Subject: is there any kernel feature to disable IPsec processing even if
 policy and sa are present
Date: Tue, 13 May 2014 15:36:24 +0530
Message-ID: <CAEzCmYAAzBJ1HDCiYEcsztVHC5LwNgFehzEWp+mgtSN0jbPDAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, Achal Verma <achalv18@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f66.google.com ([209.85.213.66]:49854 "EHLO
	mail-yh0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933175AbaEMKYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 06:24:22 -0400
Received: by mail-yh0-f66.google.com with SMTP id f73so33260yha.9
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 03:24:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I know disable_xfrm and disable_policy can be used to avoid IPsec
processing on packets hitting particular network interface.
But is there any way so that I can disable ipsec processing on per
policy/sa basis .

scenario is like my same interface is acting as endpoint for both
tunnel and transport modes but my requirement is to do ipsec
processing only on tunneled packets and avoid that for transport mode.

Our implementation is using these sysctl parameters(disable_policy and
disable_xfrm) , so I expect they will not be deprecated and removed in
near future releases.
