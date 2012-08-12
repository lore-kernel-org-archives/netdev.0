From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 01/15] net: proc entry showing inodes on sockfs and
 their types
Date: Sat, 11 Aug 2012 21:04:34 -0700 (PDT)
Message-ID: <20120811.210434.961670950702666620.davem@davemloft.net>
References: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yamato@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Sorry, you cannot do this.

You are adding a new lock and insert into a global list for
pretty much every socket created, that will destroy performance.

You also cannnot add new fields to socket listing procfs files,
it will break existing application which depend upon the existing
exact layout of those fields.
