From: kaber@trash.net
Subject: [PATCH 0/2] netfilter: SIP conntrack fixes
Date: Tue, 17 May 2011 07:26:52 +0200
Message-ID: <1305610014-3056-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

following are two fixes for the SIP connection tracking helper:

- missing validation of the Content-Length field, which is used to calculate
  the end of the SDP body

- incorrect parsing of the SIP message, resulting in a failure to locate
  the SDP body when the Content-Length field is not the last member of the
  SIP message

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!
