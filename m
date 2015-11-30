From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] vhost: replace % with & on data path
Date: Mon, 30 Nov 2015 17:05:46 +0800
Message-ID: <201511301705.vFlHJzKh%fengguang.wu@intel.com>
References: <1448872427-11623-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="/9DWx/yDrRhgMJTb"
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1448872427-11623-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Michael,

[auto build test ERROR on: v4.4-rc3]
[also build test ERROR on: next-20151127]

url:    https://github.com/0day-ci/linux/commits/Michael-S-Tsirkin/vhost-replace-with-on-data-path/20151130-163704
config: i386-randconfig-s1-201548 (attached as .config)
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All error/warnings (new ones prefixed by >>):

   drivers/vhost/vhost.c: In function 'vhost_get_vq_desc':
>> drivers/vhost/vhost.c:1345:6: warning: unused variable 'ret' [-Wunused-variable]
     int ret;
         ^
>> drivers/vhost/vhost.c:1344:13: warning: unused variable 'ring_head' [-Wunused-variable]
     __virtio16 ring_head;
                ^
>> drivers/vhost/vhost.c:1341:24: warning: unused variable 'found' [-Wunused-variable]
     unsigned int i, head, found = 0;
                           ^
>> drivers/vhost/vhost.c:1341:18: warning: unused variable 'head' [-Wunused-variable]
     unsigned int i, head, found = 0;
                     ^
>> drivers/vhost/vhost.c:1341:15: warning: unused variable 'i' [-Wunused-variable]
     unsigned int i, head, found = 0;
                  ^
>> drivers/vhost/vhost.c:1340:20: warning: unused variable 'desc' [-Wunused-variable]
     struct vring_desc desc;
                       ^
   drivers/vhost/vhost.c: At top level:
>> drivers/vhost/vhost.c:1373:2: error: expected identifier or '(' before 'if'
     if (unlikely(__get_user(ring_head,
     ^
   In file included from include/uapi/linux/stddef.h:1:0,
                    from include/linux/stddef.h:4,
                    from include/uapi/linux/posix_types.h:4,
                    from include/uapi/linux/types.h:13,
                    from include/linux/types.h:5,
                    from include/uapi/asm-generic/fcntl.h:4,
                    from arch/x86/include/uapi/asm/fcntl.h:1,
                    from include/uapi/linux/fcntl.h:4,
                    from include/linux/fcntl.h:4,
                    from include/linux/eventfd.h:11,
                    from drivers/vhost/vhost.c:14:
>> arch/x86/include/asm/uaccess.h:414:2: error: expected identifier or '(' before ')' token
    })
     ^
   include/linux/compiler.h:137:45: note: in definition of macro 'unlikely'
    #  define unlikely(x) (__builtin_constant_p(x) ? !!(x) : __branch_check__(x, 0))
                                                ^
   arch/x86/include/asm/uaccess.h:479:2: note: in expansion of macro '__get_user_nocheck'
     __get_user_nocheck((x), (ptr), sizeof(*(ptr)))
     ^
>> drivers/vhost/vhost.c:1373:15: note: in expansion of macro '__get_user'
     if (unlikely(__get_user(ring_head,
                  ^
>> arch/x86/include/asm/uaccess.h:414:2: error: expected identifier or '(' before ')' token
    })
     ^
   include/linux/compiler.h:137:53: note: in definition of macro 'unlikely'
    #  define unlikely(x) (__builtin_constant_p(x) ? !!(x) : __branch_check__(x, 0))
                                                        ^
   arch/x86/include/asm/uaccess.h:479:2: note: in expansion of macro '__get_user_nocheck'
     __get_user_nocheck((x), (ptr), sizeof(*(ptr)))
     ^
>> drivers/vhost/vhost.c:1373:15: note: in expansion of macro '__get_user'
     if (unlikely(__get_user(ring_head,
                  ^
>> include/linux/compiler.h:126:4: error: expected identifier or '(' before ')' token
      })
       ^
   include/linux/compiler.h:137:58: note: in expansion of macro '__branch_check__'
    #  define unlikely(x) (__builtin_constant_p(x) ? !!(x) : __branch_check__(x, 0))
                                                             ^
>> drivers/vhost/vhost.c:1373:6: note: in expansion of macro 'unlikely'
     if (unlikely(__get_user(ring_head,
         ^
>> drivers/vhost/vhost.c:1381:2: warning: data definition has no type or storage class
     head = vhost16_to_cpu(vq, ring_head);
     ^
>> drivers/vhost/vhost.c:1381:2: error: type defaults to 'int' in declaration of 'head' [-Werror=implicit-int]
>> drivers/vhost/vhost.c:1381:24: error: 'vq' undeclared here (not in a function)
     head = vhost16_to_cpu(vq, ring_head);
                           ^
>> drivers/vhost/vhost.c:1381:28: error: 'ring_head' undeclared here (not in a function)
     head = vhost16_to_cpu(vq, ring_head);
                               ^
   drivers/vhost/vhost.c:1384:2: error: expected identifier or '(' before 'if'
     if (unlikely(head >= vq->num)) {
     ^
   In file included from include/uapi/linux/stddef.h:1:0,
                    from include/linux/stddef.h:4,
                    from include/uapi/linux/posix_types.h:4,
                    from include/uapi/linux/types.h:13,
                    from include/linux/types.h:5,
                    from include/uapi/asm-generic/fcntl.h:4,
                    from arch/x86/include/uapi/asm/fcntl.h:1,
                    from include/uapi/linux/fcntl.h:4,
                    from include/linux/fcntl.h:4,
                    from include/linux/eventfd.h:11,
                    from drivers/vhost/vhost.c:14:
>> include/linux/compiler.h:126:4: error: expected identifier or '(' before ')' token
      })
       ^
   include/linux/compiler.h:137:58: note: in expansion of macro '__branch_check__'
    #  define unlikely(x) (__builtin_constant_p(x) ? !!(x) : __branch_check__(x, 0))
                                                             ^
   drivers/vhost/vhost.c:1384:6: note: in expansion of macro 'unlikely'
     if (unlikely(head >= vq->num)) {
         ^
   drivers/vhost/vhost.c:1391:2: warning: data definition has no type or storage class
     *out_num = *in_num = 0;
     ^
>> drivers/vhost/vhost.c:1391:3: error: type defaults to 'int' in declaration of 'out_num' [-Werror=implicit-int]
     *out_num = *in_num = 0;
      ^
>> drivers/vhost/vhost.c:1391:14: error: 'in_num' undeclared here (not in a function)
     *out_num = *in_num = 0;
                 ^
   drivers/vhost/vhost.c:1392:2: error: expected identifier or '(' before 'if'
     if (unlikely(log))
     ^
   In file included from include/uapi/linux/stddef.h:1:0,
                    from include/linux/stddef.h:4,
                    from include/uapi/linux/posix_types.h:4,
                    from include/uapi/linux/types.h:13,
                    from include/linux/types.h:5,
                    from include/uapi/asm-generic/fcntl.h:4,
                    from arch/x86/include/uapi/asm/fcntl.h:1,
                    from include/uapi/linux/fcntl.h:4,
                    from include/linux/fcntl.h:4,
                    from include/linux/eventfd.h:11,
                    from drivers/vhost/vhost.c:14:

vim +1373 drivers/vhost/vhost.c

d5675bd2 Michael S. Tsirkin 2010-06-24  1334   * returned on error. */
47283bef Michael S. Tsirkin 2014-06-05  1335  int vhost_get_vq_desc(struct vhost_virtqueue *vq,
3a4d5c94 Michael S. Tsirkin 2010-01-14  1336  		      struct iovec iov[], unsigned int iov_size,
3a4d5c94 Michael S. Tsirkin 2010-01-14  1337  		      unsigned int *out_num, unsigned int *in_num,
3a4d5c94 Michael S. Tsirkin 2010-01-14  1338  		      struct vhost_log *log, unsigned int *log_num)
3a4d5c94 Michael S. Tsirkin 2010-01-14  1339  {
3a4d5c94 Michael S. Tsirkin 2010-01-14 @1340  	struct vring_desc desc;
3a4d5c94 Michael S. Tsirkin 2010-01-14 @1341  	unsigned int i, head, found = 0;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1342  	u16 last_avail_idx;
3b1bbe89 Michael S. Tsirkin 2014-10-24  1343  	__virtio16 avail_idx;
3b1bbe89 Michael S. Tsirkin 2014-10-24 @1344  	__virtio16 ring_head;
3a4d5c94 Michael S. Tsirkin 2010-01-14 @1345  	int ret;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1346  
3a4d5c94 Michael S. Tsirkin 2010-01-14  1347  	/* Check it isn't doing very strange things with descriptor numbers. */
3a4d5c94 Michael S. Tsirkin 2010-01-14  1348  	last_avail_idx = vq->last_avail_idx;
3b1bbe89 Michael S. Tsirkin 2014-10-24  1349  	if (unlikely(__get_user(avail_idx, &vq->avail->idx))) {
3a4d5c94 Michael S. Tsirkin 2010-01-14  1350  		vq_err(vq, "Failed to access avail idx at %p\n",
3a4d5c94 Michael S. Tsirkin 2010-01-14  1351  		       &vq->avail->idx);
d5675bd2 Michael S. Tsirkin 2010-06-24  1352  		return -EFAULT;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1353  	}
3b1bbe89 Michael S. Tsirkin 2014-10-24  1354  	vq->avail_idx = vhost16_to_cpu(vq, avail_idx);
3a4d5c94 Michael S. Tsirkin 2010-01-14  1355  
7b3384fc Michael S. Tsirkin 2010-07-01  1356  	if (unlikely((u16)(vq->avail_idx - last_avail_idx) > vq->num)) {
3a4d5c94 Michael S. Tsirkin 2010-01-14  1357  		vq_err(vq, "Guest moved used index from %u to %u",
3a4d5c94 Michael S. Tsirkin 2010-01-14  1358  		       last_avail_idx, vq->avail_idx);
d5675bd2 Michael S. Tsirkin 2010-06-24  1359  		return -EFAULT;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1360  	}
3a4d5c94 Michael S. Tsirkin 2010-01-14  1361  
3a4d5c94 Michael S. Tsirkin 2010-01-14  1362  	/* If there's nothing new since last we looked, return invalid. */
3a4d5c94 Michael S. Tsirkin 2010-01-14  1363  	if (vq->avail_idx == last_avail_idx)
3a4d5c94 Michael S. Tsirkin 2010-01-14  1364  		return vq->num;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1365  
3a4d5c94 Michael S. Tsirkin 2010-01-14  1366  	/* Only get avail ring entries after they have been exposed by guest. */
5659338c Michael S. Tsirkin 2010-02-01  1367  	smp_rmb();
3a4d5c94 Michael S. Tsirkin 2010-01-14  1368  
07a08023 Michael S. Tsirkin 2015-11-30 @1369  	}
07a08023 Michael S. Tsirkin 2015-11-30  1370  
3a4d5c94 Michael S. Tsirkin 2010-01-14  1371  	/* Grab the next descriptor number they're advertising, and increment
3a4d5c94 Michael S. Tsirkin 2010-01-14  1372  	 * the index we've seen. */
3b1bbe89 Michael S. Tsirkin 2014-10-24 @1373  	if (unlikely(__get_user(ring_head,
07a08023 Michael S. Tsirkin 2015-11-30  1374  				&vq->avail->ring[last_avail_idx & (vq->num - 1)]))) {
3a4d5c94 Michael S. Tsirkin 2010-01-14  1375  		vq_err(vq, "Failed to read head: idx %d address %p\n",
3a4d5c94 Michael S. Tsirkin 2010-01-14  1376  		       last_avail_idx,
3a4d5c94 Michael S. Tsirkin 2010-01-14  1377  		       &vq->avail->ring[last_avail_idx % vq->num]);
d5675bd2 Michael S. Tsirkin 2010-06-24  1378  		return -EFAULT;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1379  	}
3a4d5c94 Michael S. Tsirkin 2010-01-14  1380  
3b1bbe89 Michael S. Tsirkin 2014-10-24 @1381  	head = vhost16_to_cpu(vq, ring_head);
3b1bbe89 Michael S. Tsirkin 2014-10-24  1382  
3a4d5c94 Michael S. Tsirkin 2010-01-14  1383  	/* If their number is silly, that's an error. */
7b3384fc Michael S. Tsirkin 2010-07-01 @1384  	if (unlikely(head >= vq->num)) {
3a4d5c94 Michael S. Tsirkin 2010-01-14  1385  		vq_err(vq, "Guest says index %u > %u is available",
3a4d5c94 Michael S. Tsirkin 2010-01-14  1386  		       head, vq->num);
d5675bd2 Michael S. Tsirkin 2010-06-24  1387  		return -EINVAL;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1388  	}
3a4d5c94 Michael S. Tsirkin 2010-01-14  1389  
3a4d5c94 Michael S. Tsirkin 2010-01-14  1390  	/* When we start there are none of either input nor output. */
3a4d5c94 Michael S. Tsirkin 2010-01-14 @1391  	*out_num = *in_num = 0;
3a4d5c94 Michael S. Tsirkin 2010-01-14 @1392  	if (unlikely(log))
3a4d5c94 Michael S. Tsirkin 2010-01-14  1393  		*log_num = 0;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1394  
3a4d5c94 Michael S. Tsirkin 2010-01-14 @1395  	i = head;
3a4d5c94 Michael S. Tsirkin 2010-01-14 @1396  	do {
3a4d5c94 Michael S. Tsirkin 2010-01-14  1397  		unsigned iov_count = *in_num + *out_num;
7b3384fc Michael S. Tsirkin 2010-07-01  1398  		if (unlikely(i >= vq->num)) {
3a4d5c94 Michael S. Tsirkin 2010-01-14  1399  			vq_err(vq, "Desc index is %u > %u, head = %u",
3a4d5c94 Michael S. Tsirkin 2010-01-14  1400  			       i, vq->num, head);
d5675bd2 Michael S. Tsirkin 2010-06-24  1401  			return -EINVAL;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1402  		}
7b3384fc Michael S. Tsirkin 2010-07-01  1403  		if (unlikely(++found > vq->num)) {
3a4d5c94 Michael S. Tsirkin 2010-01-14  1404  			vq_err(vq, "Loop detected: last one at %u "
3a4d5c94 Michael S. Tsirkin 2010-01-14  1405  			       "vq size %u head %u\n",
3a4d5c94 Michael S. Tsirkin 2010-01-14  1406  			       i, vq->num, head);
d5675bd2 Michael S. Tsirkin 2010-06-24  1407  			return -EINVAL;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1408  		}
fcc042a2 Michael S. Tsirkin 2011-03-06  1409  		ret = __copy_from_user(&desc, vq->desc + i, sizeof desc);
7b3384fc Michael S. Tsirkin 2010-07-01  1410  		if (unlikely(ret)) {
3a4d5c94 Michael S. Tsirkin 2010-01-14  1411  			vq_err(vq, "Failed to get descriptor: idx %d addr %p\n",
3a4d5c94 Michael S. Tsirkin 2010-01-14  1412  			       i, vq->desc + i);
d5675bd2 Michael S. Tsirkin 2010-06-24  1413  			return -EFAULT;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1414  		}
3b1bbe89 Michael S. Tsirkin 2014-10-24  1415  		if (desc.flags & cpu_to_vhost16(vq, VRING_DESC_F_INDIRECT)) {
47283bef Michael S. Tsirkin 2014-06-05  1416  			ret = get_indirect(vq, iov, iov_size,
3a4d5c94 Michael S. Tsirkin 2010-01-14  1417  					   out_num, in_num,
3a4d5c94 Michael S. Tsirkin 2010-01-14  1418  					   log, log_num, &desc);
7b3384fc Michael S. Tsirkin 2010-07-01  1419  			if (unlikely(ret < 0)) {
3a4d5c94 Michael S. Tsirkin 2010-01-14  1420  				vq_err(vq, "Failure detected "
3a4d5c94 Michael S. Tsirkin 2010-01-14  1421  				       "in indirect descriptor at idx %d\n", i);
d5675bd2 Michael S. Tsirkin 2010-06-24  1422  				return ret;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1423  			}
3a4d5c94 Michael S. Tsirkin 2010-01-14  1424  			continue;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1425  		}
3a4d5c94 Michael S. Tsirkin 2010-01-14  1426  
3b1bbe89 Michael S. Tsirkin 2014-10-24  1427  		ret = translate_desc(vq, vhost64_to_cpu(vq, desc.addr),
3b1bbe89 Michael S. Tsirkin 2014-10-24  1428  				     vhost32_to_cpu(vq, desc.len), iov + iov_count,
3a4d5c94 Michael S. Tsirkin 2010-01-14  1429  				     iov_size - iov_count);
7b3384fc Michael S. Tsirkin 2010-07-01  1430  		if (unlikely(ret < 0)) {
3a4d5c94 Michael S. Tsirkin 2010-01-14  1431  			vq_err(vq, "Translation failure %d descriptor idx %d\n",
3a4d5c94 Michael S. Tsirkin 2010-01-14  1432  			       ret, i);
d5675bd2 Michael S. Tsirkin 2010-06-24  1433  			return ret;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1434  		}
3b1bbe89 Michael S. Tsirkin 2014-10-24  1435  		if (desc.flags & cpu_to_vhost16(vq, VRING_DESC_F_WRITE)) {
3a4d5c94 Michael S. Tsirkin 2010-01-14  1436  			/* If this is an input descriptor,
3a4d5c94 Michael S. Tsirkin 2010-01-14  1437  			 * increment that count. */
3a4d5c94 Michael S. Tsirkin 2010-01-14  1438  			*in_num += ret;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1439  			if (unlikely(log)) {
3b1bbe89 Michael S. Tsirkin 2014-10-24  1440  				log[*log_num].addr = vhost64_to_cpu(vq, desc.addr);
3b1bbe89 Michael S. Tsirkin 2014-10-24  1441  				log[*log_num].len = vhost32_to_cpu(vq, desc.len);
3a4d5c94 Michael S. Tsirkin 2010-01-14  1442  				++*log_num;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1443  			}
3a4d5c94 Michael S. Tsirkin 2010-01-14  1444  		} else {
3a4d5c94 Michael S. Tsirkin 2010-01-14  1445  			/* If it's an output descriptor, they're all supposed
3a4d5c94 Michael S. Tsirkin 2010-01-14  1446  			 * to come before any input descriptors. */
7b3384fc Michael S. Tsirkin 2010-07-01  1447  			if (unlikely(*in_num)) {
3a4d5c94 Michael S. Tsirkin 2010-01-14  1448  				vq_err(vq, "Descriptor has out after in: "
3a4d5c94 Michael S. Tsirkin 2010-01-14  1449  				       "idx %d\n", i);
d5675bd2 Michael S. Tsirkin 2010-06-24  1450  				return -EINVAL;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1451  			}
3a4d5c94 Michael S. Tsirkin 2010-01-14  1452  			*out_num += ret;
3a4d5c94 Michael S. Tsirkin 2010-01-14  1453  		}
3b1bbe89 Michael S. Tsirkin 2014-10-24 @1454  	} while ((i = next_desc(vq, &desc)) != -1);
3a4d5c94 Michael S. Tsirkin 2010-01-14  1455  
3a4d5c94 Michael S. Tsirkin 2010-01-14  1456  	/* On success, increment avail index. */
3a4d5c94 Michael S. Tsirkin 2010-01-14 @1457  	vq->last_avail_idx++;
8ea8cf89 Michael S. Tsirkin 2011-05-20  1458  
8ea8cf89 Michael S. Tsirkin 2011-05-20  1459  	/* Assume notifications from guest are disabled at this point,
8ea8cf89 Michael S. Tsirkin 2011-05-20  1460  	 * if they aren't we would need to update avail_event index. */
8ea8cf89 Michael S. Tsirkin 2011-05-20 @1461  	BUG_ON(!(vq->used_flags & VRING_USED_F_NO_NOTIFY));
3a4d5c94 Michael S. Tsirkin 2010-01-14 @1462  	return head;
3a4d5c94 Michael S. Tsirkin 2010-01-14 @1463  }
6ac1afbf Asias He           2013-05-06  1464  EXPORT_SYMBOL_GPL(vhost_get_vq_desc);
3a4d5c94 Michael S. Tsirkin 2010-01-14  1465  
3a4d5c94 Michael S. Tsirkin 2010-01-14  1466  /* Reverse the effect of vhost_get_vq_desc. Useful for error handling. */

:::::: The code at line 1373 was first introduced by commit
:::::: 3b1bbe89351a8003857aeb5cbef3595f5d0ee609 vhost: virtio 1.0 endian-ness support

:::::: TO: Michael S. Tsirkin <mst@redhat.com>
:::::: CC: Michael S. Tsirkin <mst@redhat.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--/9DWx/yDrRhgMJTb
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--/9DWx/yDrRhgMJTb--
