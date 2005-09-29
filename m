From: "Shekhar Kshirsagar" <shekhark@juniper.net>
Subject: netfilter hooks for ESP over UDP packets are not invoked
Date: Thu, 29 Sep 2005 11:25:13 -0700
Message-ID: <EF311E6F9B0B0848A49ED20B06E9CB2705B47B03@gluon.jnpr.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

iptables rules to match ESP packets work fine for raw ESP, but they do
not work for ESP over UDP packets. 

Looking into the code, it seems that netfilter hooks are not invoked for
ESP packets that came over UDP. 
Does somebody already have a patch to resolve this issue?

Thanks,
Shekhar
