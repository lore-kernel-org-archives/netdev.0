From: Dmitry Mishin <dim@openvz.org>
Subject: Re: [Devel] Re: [RFC] network namespaces
Date: Sat, 9 Sep 2006 11:57:24 +0400
Message-ID: <200609091157.24734.dim@openvz.org>
References: <20060815182029.A1685@castle.nmd.msu.ru> <200609081710.09124.dim@openvz.org> <20060908181154.GA8745@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kirill Korotaev <dev@sw.ru>, devel@openvz.org,
	Kir Kolyshkin <kir@openvz.org>, Andrey Savochkin <saw@sw.ru>,
	alexey@sw.ru, Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:45342 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S932346AbWIIH6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Sep 2006 03:58:45 -0400
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20060908181154.GA8745@MAIL.13thfloor.at>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 08 September 2006 22:11, Herbert Poetzl wrote:
> actually the light-weight ip isolation runs perfectly
> fine _without_ CAP_NET_ADMIN, as you do not want the
> guest to be able to mess with the 'configured' ips at
> all (not to speak of interfaces here)
It was only an example. I'm thinking about how to implement flexible solution, 
which permits light-weight ip isolation as well as full-fledged netwrok 
virtualization. Another solution is to split CONFIG_NET_NAMESPACE. Is it good 
for you?

-- 
Thanks,
Dmitry.
