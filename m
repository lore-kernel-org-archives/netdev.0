From: David Heidelberger <david.heidelberger@ixit.cz>
Subject: iputils: maintanace fork
Date: Tue, 22 Apr 2014 14:07:41 +0200
Message-ID: <3d2e1f5d3adfab1bae799b8a557e87b8@ixit.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94-84-246-161.wendulka.net ([84.246.161.94]:42417 "EHLO ixit.cz"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755029AbaDVLJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 07:09:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

because latest iputils release (and also last commit in git repo.) 
happened more than year ago and bugs of iputils differs on every 
distrubution, because of different number of used patches I decided to 
work on iputils to get all important patches together.

Project can be found on github [1], build bot on travis-ci [2].

For Yoshfuji Hideaki, first I want to apologize for starting this 
without notifying you. I though you're not interested anymore, but some 
people pointed me that you response to emails, only it takes more time. 
If you're still interested in maintaining iputils, I'm ready to give you 
full access to github and travis-ci :)

For people with difficulties: report them to github issues, to keep 
track of them.

For people with patches: please rebase them against lastest work in git 
repository and submit them as pull request (this ensure automatic build 
test). Also please try attach some command to test correctness of your 
changes.

For package maintainers: At moment writing there is RELEASE s20140420 on 
github, with integrated musl-libc fixes (mostly headers) and most of 
Debian and Gentoo patches. If you want ensure that quality of code is 
high enough, read git changelog [3] and travis-ci build history [2] with 
gcc-4.8 and clang.

Thank you for reading
David Heidelberger (okias)

[1] https://github.com/iputils/iputils
[2] https://travis-ci.org/iputils/iputils
[3] https://github.com/iputils/iputils/commits/master
[4] http://www.musl-libc.org/
