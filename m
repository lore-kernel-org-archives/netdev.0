From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH]: Fix off-by-one in max protocol-type check
Date: Fri, 28 May 2004 12:53:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40B71A1C.5080400@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch fixes an off-by-one in inet_register_protosw and
inet6_register_protosw. inetsw is an array of size SOCK_MAX,
the check allows access to index SOCK_MAX. Patch applies
to 2.4 and 2.6.

Regards
Patrick
