From: Markku Savela <msa@moth.iki.fi>
Subject: Re: [Patch net-next v3 9/9] selinux: use generic union inet_addr
Date: Tue, 20 Aug 2013 17:48:00 +0300
Message-ID: <521381A0.9050304@moth.iki.fi>
References: <1376907278-26377-1-git-send-email-amwang@redhat.com>  <1376907278-26377-10-git-send-email-amwang@redhat.com>  <52127336.3080209@schaufler-ca.com>  <20130819.125026.636442915180863272.davem@davemloft.net>  <5212915F.20905@schaufler-ca.com> <1377003677.13412.5.camel@cr0> <52137CFF.70601@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, james.l.morris@oracle.com,
	sds@tycho.nsa.gov, eparis@parisplace.org, pmoore@redhat.com,
	linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <52137CFF.70601@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Imho, the patch doesn't go far enough actually. What should be done:

- get rid of the union
- use IPv6 format only
- store IPv4 addresses in IPv4 mapped format


