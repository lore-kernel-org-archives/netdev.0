From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [patch -mm] net namespace: empty framework
Date: Wed, 22 Nov 2006 14:53:51 +0100
Message-ID: <4564566F.7030202@fr.ibm.com>
References: <4563007B.9010202@fr.ibm.com> <4563046B.6040909@sw.ru>	<45633EDF.3050309@fr.ibm.com> <200611221121.59322.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, Kirill Korotaev <dev@sw.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Herbert Poetzl <herbert@13thfloor.at>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:49318 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S1755886AbWKVNx5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 08:53:57 -0500
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200611221121.59322.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Dmitry Mishin wrote:

> This patch looks acceptable for us.

good. shall we merge it then ? see comment below.

> BTW, Daniel, we agreed to be based on the Andrey's patchset. I do not see a
> reason, why Cedric force us to make some unnecessary work and move existent
> patchset over his interface.

yeah it's a bit different from andrey's but not that much and it's more in 
the spirit of uts and ipc namespace (and user namespace if that reaches the
kernel one day :) so that's why i made the small changes.

It also helping the nsproxy/namespace syscalls to have a similar interface
to manipulate namespaces. who knows, soon we might be able to have a 'struct
namespace' with a ops field to define new namespace types ? 

I can also send a empty framework for user namespace  ;)

thanks for reacting !

C.
