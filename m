From: Paul Moore <pmoore@redhat.com>
Subject: Re: [RFC PATCH v2 3/3] tun: fix LSM/SELinux labeling of tun/tap devices
Date: Mon, 10 Dec 2012 17:21:44 -0500
Message-ID: <2030873.8I84M3f4cr@sifl>
References: <20121205202144.18626.61966.stgit@localhost> <20121210175035.GA31856@redhat.com> <CACLa4pu6UCpzKfscVoEPzLySHitta1yTqPa7cA0d=xUj5ws6HA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	SE-Linux <selinux@tycho.nsa.gov>, jasowang@redhat.com
To: Eric Paris <eparis@parisplace.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CACLa4pu6UCpzKfscVoEPzLySHitta1yTqPa7cA0d=xUj5ws6HA@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, December 10, 2012 01:42:12 PM Eric Paris wrote:
> Let me abstract a little here Paul.  Lets say user A starts an
> unclassified process and a top secret process.  SELinux policy darn
> well better be able to enforce that they can not attach to the same
> tun.
> 
> Am I missing something here?

Relax, all the SELinux enforced separation still exists, and works.  We're 
just fixing the LSM/SELinux stuff that was broken with the multiqueue addition 
and adding a new SELinux permission to control access to the new queue 
command.

What we are currently discussing is DAC only.  While Michael have different 
opinions on how to solve the DAC issues, we agree that SELinux works 
correctly.

-- 
paul moore
security and virtualization @ redhat

