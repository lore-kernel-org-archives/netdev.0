From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 12:49:36 -0700 (PDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20020906.124936.34476547.davem@redhat.com>
References: <20020906.115804.109349169.davem@redhat.com>
	<E17nP9R-000453-00@w-gerrit2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Martin.Bligh@us.ibm.com, hadi@cyberus.ca, tcw@tempest.prismnet.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: gh@us.ibm.com
In-Reply-To: <E17nP9R-000453-00@w-gerrit2>
List-Id: netdev.vger.kernel.org

   From: Gerrit Huizenga <gh@us.ibm.com>
   Date: Fri, 06 Sep 2002 12:52:15 -0700
   
   So if apache were using a listen()/clone()/accept()/exec() combo rather than a
   full listen()/fork()/exec() model it would see most of the same benefits?

Apache would need to do some more, such as do something about
cpu affinity and do the non-blocking VFS tricks Tux does too.

To be honest, I'm not going to sit here all day long and explain how
Tux works.  I'm not even too knowledgable about the precise details of
it's implementation.  Besides, the code is freely available and not
too complex, so you can go have a look for yourself :-)
